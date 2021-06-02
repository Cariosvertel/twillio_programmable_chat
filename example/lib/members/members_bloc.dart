import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:twilio_programmable_chat/twilio_programmable_chat.dart';

class MembersBloc {
  ChatClient chatClient;
  ChannelDescriptor channelDescriptor;
  late Channel channel;

  late BehaviorSubject<MemberData> _membersSubject;
  late ValueStream<MemberData> membersStream;

  late List<StreamSubscription> _subscriptions;
  StreamSubscription? _channelSyncSubscription;
  final Map<String?, UserDescriptor> _userDescriptorMap = {};

  Map<String?, UserDescriptor> get userDescriptorMap => _userDescriptorMap;

  MembersBloc({required this.chatClient, required this.channelDescriptor}) {
    _membersSubject = BehaviorSubject<MemberData>();
    _membersSubject.add(MemberData());

    membersStream = _membersSubject.stream;
    _subscriptions = <StreamSubscription>[];

    channelDescriptor.getChannel().then((channel) {
      var _channel = channel;
      if (_channel != null) {
        this.channel = _channel;

        if (_channel.hasSynchronized) {
          _getMembers();
        } else {
          _channelSyncSubscription = _channel.onSynchronizationChanged.listen((event) async {
            if (event.synchronizationStatus == ChannelSynchronizationStatus.ALL) {
              await _getMembers();
              await _channelSyncSubscription?.cancel();
              _channelSyncSubscription = null;
            }
          });
        }

        _subscriptions.add(_channel.onMemberAdded.listen(_onMemberAdded));
        _subscriptions.add(_channel.onMemberUpdated.listen(_onMemberUpdated));
        _subscriptions.add(_channel.onMemberDeleted.listen(_onMemberDeleted));
      }
    });
  }

  Future refresh() async {
    await _getMembers();
  }

  Future _getMembers() async {
    var c = await channelDescriptor.getChannel();
    var membersList = await c?.members.getMembersList();
    if (membersList != null) {
      for (var member in membersList) {
        final userDescriptor = await member.getUserDescriptor();
        _userDescriptorMap[member.sid] = userDescriptor;
      }
      _membersSubject.add(MemberData(members: membersList, userDescriptors: _userDescriptorMap));
    }
  }

  Future _onMemberAdded(Member member) async {
    var memberData = _membersSubject.value;
    var userDescriptor = await member.getUserDescriptor();
    memberData.members.add(member);
    memberData.userDescriptors[member.sid] = userDescriptor;
    _membersSubject.add(memberData);
  }

  Future _onMemberUpdated(MemberUpdatedEvent event) async {
    var memberData = _membersSubject.value;
    var userDescriptor = await event.member.getUserDescriptor();
    var memberIndex = memberData.members.indexWhere((m) => m.sid == event.member.sid);
    memberData.members[memberIndex] = event.member;
    memberData.userDescriptors[event.member.sid] = userDescriptor;
    _membersSubject.add(memberData);
  }

  void _onMemberDeleted(Member member) {
    var memberData = _membersSubject.value;
    memberData.members.removeWhere((m) => m.sid == member.sid);
    memberData.userDescriptors.remove(member.sid);
    _membersSubject.add(memberData);
  }

  Future dispose() async {
    await _membersSubject.close();
    _subscriptions.forEach((s) => s.cancel());
    _subscriptions.clear();
  }
}

class MemberData {
  List<Member> members;
  Map<String?, UserDescriptor> userDescriptors;

  MemberData({
    this.members = const <Member>[],
    this.userDescriptors = const <String, UserDescriptor>{},
  });
}
