// Copyright (c) 2022, Xnfo <https://github.com/tekert>
// Original license by:
// Copyright (c) 2014, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:formatter_server/protocol/protocol.dart';

/// The abstract class [ServerCommunicationChannel] defines the behavior of
/// objects that allow an [FormatServer] to receive [Request]s and to return
/// both [Response]s and [Notification]s.
abstract class ServerCommunicationChannel
{
    /// The single-subscription stream of requests.
    Stream<Request> get requests;

    /// Close the communication channel.
    void close();

    /// Send the given [notification] to the client.
    void sendNotification(Notification notification);

    /// Send the given [response] to the client.
    void sendResponse(Response response);
}
