import "package:flutter/material.dart";
import "package:simple_anime/spider/apis/duitang.dart";
import "package:simple_anime/conf.dart";

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Add AI apis as well as MCP services
    return Center(
      child: ElevatedButton(
        onPressed: () {
          // NOTE: Validate some functions here
          DuitangSpider()
              .crawl({"kw": "德克萨斯", "afterId": 0})
              .then((value) => logger.i(value));
        },
        child: Text("Get"),
      ),
    );
  }
}
