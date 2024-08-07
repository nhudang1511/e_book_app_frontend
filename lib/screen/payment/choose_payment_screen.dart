import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:e_book_app/screen/payment/vnpay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/blocs.dart';
import '../../config/shared_preferences.dart';
import '../../model/models.dart';
import '../../repository/repository.dart';
import '../../utils/show_snack_bar.dart';
import '../../widget/widget.dart';
import 'package:flutter_paypal_checkout/flutter_paypal_checkout.dart';

class ChoosePaymentScreen extends StatefulWidget {
  const ChoosePaymentScreen({super.key});

  static const String routeName = '/choose_payment';

  @override
  State<ChoosePaymentScreen> createState() => _ChoosePaymentScreenState();
}

class _ChoosePaymentScreenState extends State<ChoosePaymentScreen> {
  int money = 0;
  late DepositBloc depositBloc;
  int coins = 0;
  String coinsId = '';
  var listMoneysToCoins = {
    1: 300,
    5: 2000,
    10: 5000,
  };

  @override
  void initState() {
    super.initState();
    depositBloc = DepositBloc(DepositRepository());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => depositBloc),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<DepositBloc, DepositState>(listener: (context, state) {
            // print(state);
            if (state is AddDeposit) {
              Navigator.of(context).pop();
            }
          })
        ],
        child: Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            appBar: const CustomAppBar(
              title: "Choose Payment",
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 24,
                ),
                child: Column(
                  children: [
                    CustomRadioButton(
                      elevation: 0,
                      absoluteZeroSpacing: true,
                      unSelectedColor: Theme.of(context).colorScheme.background,
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      unSelectedBorderColor:
                          Theme.of(context).colorScheme.secondaryContainer,
                      selectedBorderColor:
                          Theme.of(context).colorScheme.background,
                      buttonLables: listMoneysToCoins.entries.map((entry) {
                        return '${entry.key} \$ = ${entry.value} coins';
                      }).toList(),
                      buttonValues: listMoneysToCoins.keys.toList(),
                      buttonTextStyle: ButtonTextStyle(
                          selectedColor: Colors.white,
                          unSelectedColor:
                              Theme.of(context).colorScheme.secondaryContainer,
                          textStyle: const TextStyle(fontSize: 16)),
                      height: 50,
                      horizontal: true,
                      radioButtonValue: (value) {
                        setState(() {
                          money = value;
                        });
                      },
                      selectedColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.8),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: CustomButton(
                        title: "Paypal",
                        onPressed: () async {
                          if (money != 0) {
                            await Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) => PaypalCheckout(
                                sandboxMode: true,
                                clientId:
                                    "AQJChLCRunMImWzjcvmAJ1CnrTMHt5HSzAr8THCu9A3-3e1D0o0wwYUPnSHLxQsNP55FfttQcRmAE5eR",
                                secretKey:
                                    "EKMIwnvm7jEQ3Czs0aXEpuNjYwnkz6r60f3wmOKD5w6ED_-Gv9pfP0Vnol9Vtr3QuAuxGLNggh-5yPlG",
                                returnURL: "success.snippetcoder.com",
                                cancelURL: "cancel.snippetcoder.com",
                                transactions: [
                                  {
                                    "amount": {
                                      "total": money,
                                      "currency": "USD",
                                      "details": {
                                        "subtotal": money,
                                        "shipping": '0',
                                        "shipping_discount": 0
                                      }
                                    },
                                    "description":
                                        "The payment transaction description.",
                                  }
                                ],
                                note:
                                    "Contact us for any questions on your order.",
                                onSuccess: (Map params) async {
                                  ShowSnackBar.success(
                                      "Success deposit money from paypal",
                                      context);
                                  if (money ==
                                      listMoneysToCoins.keys.elementAt(0)) {
                                    coins = coins +
                                        listMoneysToCoins.values.elementAt(0);
                                  } else if (money ==
                                      listMoneysToCoins.keys.elementAt(1)) {
                                    coins = coins +
                                        listMoneysToCoins.values.elementAt(1);
                                  } else if (money ==
                                      listMoneysToCoins.keys.elementAt(2)) {
                                    coins = coins +
                                        listMoneysToCoins.values.elementAt(2);
                                  }
                                  depositBloc.add(AddNewDepositEvent(
                                      deposit: Deposit(
                                          status: true,
                                          type: 'Paypal',
                                          uId: SharedService.getUserId() ?? '',
                                          coin: coins,
                                          money: money,
                                          createdAt: Timestamp.fromDate(
                                              DateTime.now()),
                                          updateAt: Timestamp.fromDate(
                                              DateTime.now()))));
                                },
                                onError: (error) {
                                  ShowSnackBar.error(
                                      "Error deposit money from paypal",
                                      context);
                                  Navigator.pop(context);
                                },
                                onCancel: () {
                                  ShowSnackBar.error("Cancelled", context);
                                },
                              ),
                            ));
                          } else {
                            CustomDialog.show(
                                context: context,
                                title: 'Please select coins to continue!',
                                dialogColor: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                                msgColor:
                                    Theme.of(context).colorScheme.background,
                                titleColor:
                                    Theme.of(context).colorScheme.background,
                                onPressed: () {
                                  Navigator.pop(context, true);
                                });
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: CustomButton(
                        title: "VNPay",
                        onPressed: () {
                          if (money != 0) {
                            final paymentUrl =
                                VNPAYFlutter.instance.generatePaymentUrl(
                              url:
                                  'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html',
                              //vnpay url, default is https://sandbox.vnpayment.vn/paymentv2/vpcpay.html
                              version: '2.0.1',
                              //version of VNPAY, default is 2.0.1
                              tmnCode: 'FMJEVP1P',
                              //vnpay tmn code, get from vnpay
                              txnRef: DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString(),
                              //ref code, default is timestamp
                              orderInfo: 'Pay ${money * 23000} VND',
                              //order info, default is Pay Order
                              amount: money * 23000,
                              //amount
                              returnUrl:
                                  'https://e-book-app-backend.onrender.com',
                              //https://sandbox.vnpayment.vn/apis/docs/huong-dan-tich-hop/#code-returnurl
                              ipAdress: '192.168.10.10',
                              //Your IP address
                              vnpayHashKey: '13NZGTEYJKQ36F2BPFB5RWWYCCR0QRP1',
                              //vnpay hash key, get from vnpay
                              vnPayHashType:
                                  'HmacSHA512', //hash type. Default is HmacSHA512, you can chang it in: https://sandbox.vnpayment.vn/merchantv2
                            );
                            VNPAYFlutter.instance.show(
                                paymentUrl: paymentUrl,
                                onPaymentSuccess: (params) {
                                  ShowSnackBar.success(
                                      "Success deposit money from VNPay",
                                      context);
                                  if (money ==
                                      listMoneysToCoins.keys.elementAt(0)) {
                                    coins = coins +
                                        listMoneysToCoins.values.elementAt(0);
                                  } else if (money ==
                                      listMoneysToCoins.keys.elementAt(1)) {
                                    coins = coins +
                                        listMoneysToCoins.values.elementAt(1);
                                  } else if (money ==
                                      listMoneysToCoins.keys.elementAt(2)) {
                                    coins = coins +
                                        listMoneysToCoins.values.elementAt(2);
                                  }
                                  depositBloc.add(AddNewDepositEvent(
                                      deposit: Deposit(
                                          coin: coins,
                                          money: money,
                                          uId: SharedService.getUserId(),
                                          type: 'VNPay',
                                          status: true,
                                          createdAt: Timestamp.fromDate(
                                              DateTime.now()),
                                          updateAt: Timestamp.fromDate(
                                              DateTime.now()))));
                                }, //on mobile transaction success
                                onPaymentError: (params) {
                                  ShowSnackBar.error(
                                      "Error deposit money from VNPay",
                                      context);
                                }, //on mobile transaction error
                                onWebPaymentComplete: () {} //only use in web
                                );
                          } else {
                            CustomDialog.show(
                                context: context,
                                title: 'Please select coins to continue!',
                                dialogColor: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                                msgColor:
                                    Theme.of(context).colorScheme.background,
                                titleColor:
                                    Theme.of(context).colorScheme.background,
                                onPressed: () {
                                  Navigator.pop(context, true);
                                });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ),
    );
  }
}
