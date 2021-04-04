// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

class _BottomSheetContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      ),
      height: 300,
      child: Column(
        children: [
          InkWell(
            child: Container(
              height: 70,
              child: Center(
                child: Text(
                  'Camera',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          InkWell(
            child: Container(
              height: 70,
              child: Center(
                child: Text(
                  'Gallery',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          InkWell(
            child: Container(
              height: 70,
              child: Center(
                child: Text(
                  'Remove',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PersistentBottomSheetDemo extends StatefulWidget {
  @override
  _PersistentBottomSheetDemoState createState() =>
      _PersistentBottomSheetDemoState();
}

class _PersistentBottomSheetDemoState
    extends State<_PersistentBottomSheetDemo> {
  VoidCallback _showBottomSheetCallback;

  @override
  void initState() {
    super.initState();
    _showBottomSheetCallback = _showPersistentBottomSheet;
  }

  void _showPersistentBottomSheet() {
    setState(() {
      // Disable the show bottom sheet button.
      _showBottomSheetCallback = null;
    });

    Scaffold.of(context)
        .showBottomSheet<void>(
          (context) {
        return _BottomSheetContent();
      },
      elevation: 25,
    )
        .closed
        .whenComplete(() {
      if (mounted) {
        setState(() {
          // Re-enable the bottom sheet button.
          _showBottomSheetCallback = _showPersistentBottomSheet;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RaisedButton(
        onPressed: _showBottomSheetCallback,
        child: Text('Hello'
          ),
      ),
    );
  }
}

