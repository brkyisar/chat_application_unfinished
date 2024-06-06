import "package:cached_network_image/cached_network_image.dart";
import "package:chat_application/helper/my_date_util.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";

import "../api/apis.dart";
import "../main.dart";
import "../models/message.dart";

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});

  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    return APIs.user.uid == widget.message.fromId
        ? _greenMessage()
        : _blueMessage();
  }

  // gönderen ve ya başka kullanıcı mesaji
  Widget _blueMessage() {
    //alıcı ve gönderici farklıysa en son okunan mesajı  güncelleme
    if (widget.message.read.isNotEmpty) {
      APIs.updateMessageReadStatus(widget.message);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
              margin: EdgeInsets.symmetric(
                  horizontal: mq.width * .04, vertical: mq.height * .01),
              padding: EdgeInsets.all(widget.message.type == Type.image
                  ? mq.width * .03
                  : mq.width * .04),
              decoration: BoxDecoration(
                  color: Color.fromARGB(255, 118, 198, 223),
                  border: Border.all(color: Color.fromARGB(255, 41, 22, 59)),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20))),
              child: widget.message.type == Type.text
                  ?
                  //texti gosterme
                  Text(
                      widget.message.msg,
                      style:
                          const TextStyle(fontSize: 15, color: Colors.black87),
                    )
                  //resmi gösterme
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: CachedNetworkImage(
                          imageUrl: widget.message.msg,
                          placeholder: (context, url) =>
                              CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                          errorWidget: (context, url, error) => Icon(
                                Icons.image,
                                size: 70,
                              )),
                    )),
        ),

        //mesaj zamanı
        Padding(
          padding: EdgeInsets.only(right: mq.width * .04),
          child: Text(
            MyDateUtil.getFormattedTime(
                context: context, time: widget.message.sent),
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ),
      ],
    );
  }

  // bizim ve ya  kullanıcı mesaji
  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //mesaj zamanı
        Row(
          children: [
            //boşluk için
            SizedBox(
              width: mq.width * .04,
            ),
            //okundu işareti
            if (widget.message.read.isNotEmpty)
              const Icon(Icons.done_all_rounded,
                  color: Colors.lightBlueAccent, size: 20),

            //okundu işareti
            const Icon(
              Icons.done_all_rounded,
              color: Colors.deepPurpleAccent,
              size: 20,
            ),

            //boşluk için
            const SizedBox(width: 2),

            //okuma zamanı
            Text(
              MyDateUtil.getFormattedTime(
                  context: context, time: widget.message.sent),
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
        Flexible(
          child: Container(
              margin: EdgeInsets.symmetric(
                  horizontal: mq.width * .04, vertical: mq.height * .01),
              padding: EdgeInsets.all(widget.message.type == Type.image
                  ? mq.width * .03
                  : mq.width * .04),
              decoration: BoxDecoration(
                  color: Color.fromARGB(255, 63, 172, 78),
                  border: Border.all(color: Color.fromARGB(255, 0, 0, 0)),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20))),
              child: widget.message.type == Type.text
                  ?
                  //texti gosterme
                  Text(
                      widget.message.msg,
                      style:
                          const TextStyle(fontSize: 15, color: Colors.black87),
                    )
                  //resmi gösterme
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: CachedNetworkImage(
                          imageUrl: widget.message.msg,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.image)),
                    )),
        ),
      ],
    );
  }
}
