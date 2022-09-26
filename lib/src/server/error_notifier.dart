import 'package:analyzer/exception/exception.dart';

/// Server may throw a [FatalException] to send a fatal error response to the
/// IDEs.
class FatalException extends CaughtException
{
    FatalException(String message, Object exception, StackTrace stackTrace)
        : super.withMessage(message, exception, stackTrace);
}
