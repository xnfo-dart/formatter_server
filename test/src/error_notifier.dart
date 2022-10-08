import 'package:analyzer/exception/exception.dart';
import 'package:analyzer/instrumentation/instrumentation.dart';

import 'package:formatter_server/src/format_server.dart';
import 'package:formatter_server/src/server/error_notifier.dart';

/// An instrumentation service to show instrumentation errors as error
/// notifications to the user.
class ErrorNotifier extends NoopInstrumentationService
{
    FormatServer? server;

    @override
    void logException(
        Object exception, [
        StackTrace? stackTrace,
        List<InstrumentationServiceAttachment>? attachments,
    ])
    {
        final server = this.server;
        if (server == null || exception is SilentException)
        {
            // Silent exceptions should not be reported to the user.
            return;
        }

        var message = 'Internal error';
        if (exception is CaughtException)
        {
            var message = exception.message;
            if (message != null)
            {
                // TODO(mfairhurst): Use the outermost exception once crash reporting is
                //  fixed and this becomes purely user-facing.
                exception = exception.rootCaughtException;
                // TODO(mfairhurst): Use the outermost message rather than the innermost
                //  exception as its own message.
                message = message;
            }
        }

        server.sendServerErrorNotification(message, exception, stackTrace,
            fatal: exception is FatalException);
    }
}
