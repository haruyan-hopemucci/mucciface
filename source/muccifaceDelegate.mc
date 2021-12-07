using Toybox.WatchUi;
using Toybox.System as Sys;
using Toybox.Lang;

class muccifaceDelegate extends WatchUi.WatchFaceDelegate
{

	function initialize() {
		WatchFaceDelegate.initialize();	
	}
	
    function onPowerBudgetExceeded(powerInfo) {
      var clock = Sys.getClockTime();
      Sys.println(Lang.format("$1$:$2$:$3$", [clock.hour, clock.min, clock.sec]));
        Sys.println( "Average execution time: " + powerInfo.executionTimeAverage );
        Sys.println( "Allowed execution time: " + powerInfo.executionTimeLimit );
        // do1hz=false;
        pbeFlg = true;
    }
}