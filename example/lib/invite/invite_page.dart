import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twilio_programmable_chat/twilio_programmable_chat.dart';
import 'package:twilio_programmable_chat_example/invite/invite_bloc.dart';
import 'package:twilio_programmable_chat_example/invite/invite_model.dart';

class InvitePage extends StatefulWidget {
  final InviteBloc inviteBloc;

  InvitePage({required this.inviteBloc});

  @override
  State<StatefulWidget> createState() => InvitePageState();

  static Widget create(
    BuildContext context,
    String myIdentity,
    ChatClient chatClient,
    ChannelDescriptor channelDescriptor,
  ) {
    return Provider<InviteBloc>(
      create: (BuildContext context) => InviteBloc(myIdentity: myIdentity, chatClient: chatClient, channelDescriptor: channelDescriptor),
      dispose: (BuildContext context, InviteBloc inviteBloc) => inviteBloc.dispose(),
      child: Consumer<InviteBloc>(
        builder: (BuildContext context, InviteBloc inviteBloc, _) => InvitePage(
          inviteBloc: inviteBloc,
        ),
      ),
    );
  }
}

class InvitePageState extends State<InvitePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text('Invite'),
      ),
      body: _buildMembersList(),
    ));
  }

  Widget _buildMembersList() {
    return StreamBuilder<InviteModel>(
      stream: widget.inviteBloc.inviteStream,
      initialData: InviteModel(),
      builder: (BuildContext context, AsyncSnapshot<InviteModel> snapshot) {
        final model = snapshot.data ?? InviteModel();
        if (model.isLoading) {
          return Center(child: CircularProgressIndicator());
        } else {
          return ListView.builder(
            itemCount: model.members.length,
            itemBuilder: (BuildContext context, int index) {
              final member = model.members[index];
              return InkWell(
                onTap: () => widget.inviteBloc.inviteToChannel(member),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(member.identity ?? ''),
                ),
              );
            },
          );
        }
      },
    );
  }
}
