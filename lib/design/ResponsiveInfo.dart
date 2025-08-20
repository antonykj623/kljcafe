
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ResponsiveInfo{


  static showLoaderDialog(BuildContext context){
    AlertDialog alert=AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(),
          Container(margin: EdgeInsets.only(left: 7),child:Text("Loading..." )),
        ],),
    );
    showDialog(barrierDismissible: false,
      context:context,
      builder:(BuildContext context){
        return alert;
      },
    );
  }

 static bool isMobile(BuildContext context)
{

  bool a=false;
  double width = MediaQuery.of(context).size.shortestSide;

  if(width<600)
    {
      a=true;
    }
  else{
    a=false;
  }

  return a;

}

static int getRandomNumber()
{
  Random random = new Random();
  int randomNumber = random.nextInt(1000000)+100;
  return randomNumber;
}


 static showAlertDialog(BuildContext context,String title,String message) {

   // set up the button
   Widget okButton = TextButton(
     child: Text("OK"),
     onPressed: () {

       Navigator.pop(context);

     },
   );

   // set up the AlertDialog
   AlertDialog alert = AlertDialog(
     title:(title.isNotEmpty)? Text(title):SizedBox.shrink(),
     content: IntrinsicHeight(
     // Set your desired height
       child: Text(message)),
     actions: [
       okButton,
     ],
   );

   // show the dialog
   showDialog(
     context: context,
     builder: (BuildContext context) {
       return alert;
     },
   );
 }


 static ShowProgressDialog(BuildContext context)
 {
   showDialog(
     context: context,
     barrierDismissible: false, // Prevents dismissing by tapping outside
     builder: (BuildContext context) {
       return Dialog(
         shape: RoundedRectangleBorder(
             borderRadius: BorderRadius.circular(10.0)),
         child: Padding(
           padding: const EdgeInsets.all(20.0),
           child: Row(
             mainAxisSize: MainAxisSize.min,
             children: [
               CircularProgressIndicator(),
               SizedBox(width: 20),
               Text("Please wait for a moment..."),
             ],
           ),
         ),
       );
     },
   );

 }





 // static bool isTab(BuildContext context)
 // {
 //
 //   bool a=false;
 //   double width = MediaQuery.of(context).size.width;
 //
 //   if(width<1024)
 //   {
 //     a=true;
 //   }
 //   else{
 //     a=false;
 //   }
 //
 //   return a;
 //
 // }
 //
 //
 // static bool isSmallMobile(BuildContext context)
 // {
 //
 //   bool a=false;
 //   double width = MediaQuery.of(context).size.width;
 //
 //   if(width<=380)
 //   {
 //     a=true;
 //   }
 //   else{
 //     a=false;
 //   }
 //
 //   return a;
 //
 // }



// static Future<String> getPriceByCountry(String countrycode,String priceparam)
// async {
//   String price="0";
//
//   final productSnapshot1 = await FirebaseFirestore.instance.collection(
//       'countryList').get();
//
//   List<dynamic>c = productSnapshot1.docs.toList();
//   bool a = false;
//
//   for (int i = 0; i < c.length; i++) {
//     QueryDocumentSnapshot ab = c[i];
//
//     var m = ab.data() as Map<String, dynamic>;
//
//
//     String name = m['name'];
//     String code = m['countrycode'];
//     String id = ab.id;
//     String conversionfactor=m['ConversionFactor'];
//
//     if(code.compareTo(countrycode)==0)
//       {
//
//         double p=double.parse(priceparam.trim());
//         double c=double.parse(conversionfactor);
//
//         double convertedprice=p*c;
//         price=convertedprice.toStringAsFixed(3);
//
//         break;
//
//       }
//
//
//   }
//
//
//
//   return price;
//
// }


 // static Future<String> getCurrencyByCountry(String countrycode)
 // async {
 //   String currency_symbol="";
 //
 //   final productSnapshot1 = await FirebaseFirestore.instance.collection(
 //       'countryList').get();
 //
 //   List<dynamic>c = productSnapshot1.docs.toList();
 //   bool a = false;
 //
 //   for (int i = 0; i < c.length; i++) {
 //     QueryDocumentSnapshot ab = c[i];
 //
 //     var m = ab.data() as Map<String, dynamic>;
 //
 //
 //     String name = m['name'];
 //     String code = m['countrycode'];
 //     String id = ab.id;
 //     String conversionfactor=m['ConversionFactor'];
 //
 //     if(code.compareTo(countrycode)==0)
 //     {
 //
 //
 //
 //       if(m.containsKey("currency_symbol"))
 //       {
 //         currency_symbol=m['currency_symbol'];
 //       }
 //
 //       break;
 //
 //     }
 //
 //
 //   }
 //
 //
 //
 //   return currency_symbol;
 //
 // }




}