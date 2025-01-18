import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:woof/models/animals.dart';

import '../../../constants.dart';
import '../image_view_screen.dart';

class ImageViewer extends StatefulWidget {
  final Animals animal;
  const ImageViewer(this.animal, {Key? key}) : super(key: key);

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  int activeIndex = 0;

  @override
  Widget build(BuildContext context) {
    var hasPic = false;
    for (var image in widget.animal.images) {
      if (image != '') {
        hasPic = true;
      }
    }

    List<dynamic> imageUrls = widget.animal.images;
    return Container(
      color: cGrayBGColor,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (hasPic)
            CarouselSlider(
              options: CarouselOptions(
                height: 200,
                enableInfiniteScroll: false,
                onPageChanged: (index, reason) => setState(
                  () => activeIndex = index,
                ),
              ),
              items: imageUrls.map((i) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      height: MediaQuery.of(context).size.height,
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            ImageViewScreen.routeName,
                            arguments: i,
                          );
                        },
                        child: Hero(
                          tag: '$i',
                          child: Image.network(
                            i.toString(),
                            fit: BoxFit.fitHeight,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  color: cSecondaryColor,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          if (hasPic)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: AnimatedSmoothIndicator(
                  activeIndex: activeIndex,
                  count: imageUrls.length,
                  effect: SlideEffect(
                    dotHeight: 12,
                    dotWidth: 12,
                    activeDotColor: cSecondaryColor,
                  ),
                ),
              ),
            ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
