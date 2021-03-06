import 'package:flutter/material.dart';
import 'package:mealio/models/favorite_model.dart';
import 'package:mealio/models/food_model.dart';
import 'package:mealio/helpers/db_helper.dart';
import 'package:mealio/services/food_service.dart';

class FoodDetailPage extends StatefulWidget {
  FoodDetailPage({
    @required this.foodId,
    @required this.foodName,
    @required this.foodPicture,
    Key key,
  }) : super(key: key);

  final String foodId;
  final String foodName;
  final String foodPicture;

  @override
  _FoodDetailPageState createState() => _FoodDetailPageState();
}

class _FoodDetailPageState extends State<FoodDetailPage> {
  List<FoodDetail> foodDetail;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _getFoodById();
    _isFavorite();
  }

  Future _getFoodById() async {
    var foodService = FoodService();
    var response = await foodService.getFoodById(widget.foodId);
    if (!mounted) return;
    setState(() {
      foodDetail = response;
    });
  }

  _isFavorite() async {
    var db = DBHelper();
    var res = await db.isFavorite(widget.foodId);
    setState(() {
      isFavorite = res ? true : false;
    });
  }

  Future saveFavorite() async {
    var db = DBHelper();
    var favorite = Favorite(
      widget.foodId,
      widget.foodName,
      widget.foodPicture,
      foodDetail[0].foodCategory,
    );
    await db.saveFavorite(favorite);
    print("saved");
  }

  deleteFavorite(foodId) {
    var db = DBHelper();
    db.deleteFavorite(foodId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: Key('FOOD_DETAIL_SCAFFOLD'),
      appBar: AppBar(
        title: Text(
          widget.foodName,
          key: Key('APP_BAR_FOOD_DETAIL'),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, false),
          key: Key('DETAIL_BACK_BUTTON'),
        ),
        actions: <Widget>[
          IconButton(
            tooltip: 'Favorite',
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
            ),
            key: Key('FAVORITE_BUTTON'),
            onPressed: () {
              setState(() {
                if (isFavorite) {
                  deleteFavorite(widget.foodId);
                  isFavorite = false;
                } else {
                  saveFavorite();
                  isFavorite = true;
                }
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: EdgeInsets.all(25.0),
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(bottom: 25.0),
                      child: Hero(
                        tag: widget.foodId,
                        child: FadeInImage.assetNetwork(
                          placeholder: 'assets/images/et.png',
                          image: widget.foodPicture,
                          key: Key('IMAGE_FOOD_DETAIL'),
                        ),
                      ),
                    ),
                    buildFoodDetail(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container buildFoodDetail() {
    if (foodDetail == null) {
      return Container(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            foodDetail[0].foodDetail,
            key: Key('FOOD_DETAIL_TEXT'),
          ),
        ),
      );
    }
  }
}
