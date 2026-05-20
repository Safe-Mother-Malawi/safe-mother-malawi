// DHO IVR Insights — reuses the same backend endpoint as admin IVR insights
// but scoped to the DHO's district context
export '../admin/ivr_insights.dart' show IvrInsights;

// Re-export as DhoIvrInsights for backward compatibility
import '../admin/ivr_insights.dart';
typedef DhoIvrInsights = IvrInsights;
