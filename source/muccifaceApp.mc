import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

var pbeFlg = false;
var isSleep = false;

class muccifaceApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {
        return [ new muccifaceView(), new muccifaceDelegate() ] as Array<Views or InputDelegates>;
    }

}

function getApp() as muccifaceApp {
    return Application.getApp() as muccifaceApp;
}