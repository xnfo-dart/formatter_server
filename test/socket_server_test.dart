// Copyright (c) 2014, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:formatter_server/protocol/protocol.dart';
import 'package:formatter_server/protocol/protocol_constants.dart';
import 'package:formatter_server/protocol/protocol_generated.dart';
//import 'package:formatter_server/src/format_server.dart';
//import 'package:formatter_server/src/analytics/analytics_manager.dart';
//import 'package:formatter_server/src/analytics/noop_analytics.dart';
//import 'package:formatter_server/src/server/crash_reporting_attachments.dart';
import 'package:formatter_server/src/socket_server.dart';

import 'package:analyzer/src/generated/engine.dart';
//import 'package:analyzer/src/generated/sdk.dart';
import 'package:test/test.dart';

//import 'package:formatter_server/src/server/error_notifier.dart'; // transfered to test subdir
import 'src/error_notifier.dart';

//import 'package:formatter_server/src/utilities/mocks.dart'; // transfered to test subdir
import 'src/utilities/mocks.dart';

void main()
{
    group('SocketServer', ()
    {
        test('createFormatServer_successful',
            SocketServerTest.createFormatServer_successful);
        test('createFormatServer_alreadyStarted',
            SocketServerTest.createFormatServer_alreadyStarted);
    });
}

class SocketServerTest
{
    static void createFormatServer_alreadyStarted()
    {
        var channel1 = MockServerChannel();
        var channel2 = MockServerChannel();
        var server = _createSocketServer(channel1);
        expect(channel1.notificationsReceived[0].event, SERVER_NOTIFICATION_CONNECTED);
        server.createFormatServer(channel2);
        channel1.expectMsgCount(notificationCount: 1);
        channel2.expectMsgCount(responseCount: 1);
        expect(channel2.responsesReceived[0].id, equals(''));
        expect(channel2.responsesReceived[0].error, isNotNull);
        expect(channel2.responsesReceived[0].error!.code,
            equals(RequestErrorCode.SERVER_ALREADY_STARTED));
        channel2
            .sendRequest(ServerShutdownParams().toRequest('0'))
            .then((Response response)
        {
            expect(response.id, equals('0'));
            var error = response.error!;
            expect(error.code, equals(RequestErrorCode.SERVER_ALREADY_STARTED));
            channel2.expectMsgCount(responseCount: 2);
        });
    }

    static Future createFormatServer_successful()
    {
        var channel = MockServerChannel();
        _createSocketServer(channel);
        channel.expectMsgCount(notificationCount: 1);
        expect(channel.notificationsReceived[0].event, SERVER_NOTIFICATION_CONNECTED);
        return channel
            .sendRequest(ServerShutdownParams().toRequest('0'))
            .then((Response response)
        {
            expect(response.id, equals('0'));
            expect(response.error, isNull);
            channel.expectMsgCount(responseCount: 1, notificationCount: 1);
        });
    }

    static SocketServer _createSocketServer(MockServerChannel channel)
    {
        final errorNotifier = ErrorNotifier();
        //final errorNotifier = NoopInstrumentationService();
        final server = SocketServer(errorNotifier);

        server.createFormatServer(channel);
        errorNotifier.server = server.formatServer;
        AnalysisEngine.instance.instrumentationService = errorNotifier;

        return server;
    }
}
