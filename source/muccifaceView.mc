import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class muccifaceView extends WatchUi.WatchFace {

    var count as Number;
    var bmpMucciLarge1;
    var bmpMucciLarge2;
    var bmpMucciSit1;
    var bmpMucciSit2;
    var shapes;
    var battOuter;
    var battCharge;
    var fontDigits;
    var fontSteps;
    var memorySteps;
    var walkStopTime;
    var isWalking;
    var _THRESHOLD_WALK_STOP = 60;
    var centerLabelType;

    // multiple devices 対応
    var _jsonSettings;
    var _screenWidth;
    var _screenHeight;
    var _mucciLTop;
    var _mucciLLeft;
    var _mucciSTop;
    var _mucciSLeft;
    var _battTop;
    var _battLeft;
    var _secCenter;
    var _secClipTop;
    var _secClipLeft;

    function initialize() {
        WatchFace.initialize();
        count = 0;
        _screenWidth = System.getDeviceSettings().screenWidth;
        _screenHeight = System.getDeviceSettings().screenHeight;
        _jsonSettings = WatchUi.loadResource(Rez.JsonData.JsonSettings);
        // jsonから設定を読み込む
        _battLeft = _jsonSettings.get("battLeft");
        _battTop = _jsonSettings.get("battTop");
        _secCenter = _screenWidth / 2;
        _secClipLeft = _secCenter - 22;
        _secClipTop = _jsonSettings.get("secClipTop");
        _mucciLLeft = _jsonSettings.get("mucciLLeft");
        _mucciLTop = _jsonSettings.get("mucciLTop");
        _mucciSLeft = _jsonSettings.get("mucciSLeft");
        _mucciSTop = _jsonSettings.get("mucciSTop");

        bmpMucciLarge1 = new WatchUi.Bitmap({
          :rezId=>Rez.Drawables.BmpMucciL1,
          :locX=>_jsonSettings.get("mucciLLeft"),
          :locY=>_jsonSettings.get("mucciLTop")
        });
        bmpMucciLarge2 = new WatchUi.Bitmap({
          :rezId=>Rez.Drawables.BmpMucciL2,
          :locX=>_jsonSettings.get("mucciLLeft"),
          :locY=>_jsonSettings.get("mucciLTop")
        });
        shapes = new Rez.Drawables.shapes();
        battOuter = new Rez.Drawables.BattOuter();
        battCharge = new WatchUi.Bitmap({
          :rezId=>Rez.Drawables.BmpCharge,
          :locX=>132,
          :locY=>130
        });
        bmpMucciSit1 = new WatchUi.Bitmap({:rezId=>Rez.Drawables.BmpMucciSit1, :locX=>_jsonSettings.get("mucciSLeft"), :locY=>_jsonSettings.get("mucciSTop")});
        bmpMucciSit2 = new WatchUi.Bitmap({:rezId=>Rez.Drawables.BmpMucciSit2, :locX=>_jsonSettings.get("mucciSLeft"), :locY=>_jsonSettings.get("mucciSTop")});
        fontDigits = WatchUi.loadResource( Rez.Fonts.font_digits );
        fontSteps = WatchUi.loadResource( Rez.Fonts.font_steps );
        memorySteps = -1;
        walkStopTime = Time.now();
        isWalking = true;
        centerLabelType = 1;
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
        View.findDrawableById("HLabel").setFont(fontDigits);
        View.findDrawableById("MLabel").setFont(fontDigits);
        View.findDrawableById("StepLabel").setFont(fontSteps);
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {

    }

    function onPartialUpdate(dc as Dc){
      // dc.setClip(80,170,44,34);
        dc.setClip(_secClipLeft,_secClipTop,44,34);
        var clockTime = System.getClockTime();
        if(clockTime.sec == 0){
          return;
        }
        // var viewSecond = View.findDrawableById("SecondLabel") as Text;
        var secString = Lang.format("$1$", [clockTime.sec.format("%02d")]);
        // viewSecond.setText(secString);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(_secCenter, _secClipTop, Graphics.FONT_NUMBER_MILD, secString, Graphics.TEXT_JUSTIFY_CENTER);
        // View.onUpdate(dc);
      // dc.setClip(124,96,18,18);
      if(clockTime.sec % 2 == 0){
        if(isWalking){
          dc.setClip(_mucciLLeft,_mucciLTop,22,28);
          if(count == 0){
            bmpMucciLarge1.draw(dc);
            count = 1;
          }else{
            bmpMucciLarge2.draw(dc);
            count = 0;
          }
        }else{
          dc.setClip(_mucciSLeft,_mucciSTop,22,17);
          if(count == 0){
            bmpMucciSit1.draw(dc);
            count = 1;
          }else{
            bmpMucciSit2.draw(dc);
            count = 0;
          }
        }
      }
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
      dc.setClip(0,0,_screenWidth,_screenHeight);
        // Get and show the current time
        var clockTime = System.getClockTime();
        var hview = View.findDrawableById("HLabel") as Text;
        // var str = Lang.format("$1$",[clockTime.hour.format("%02d")]);
        // hview.setText(str);
        hview.setText(clockTime.hour.format("%02d"));
        var mview = View.findDrawableById("MLabel") as Text;
        var str = Lang.format("$1$",[clockTime.min.format("%02d")]);
        mview.setText(str);
        
        var viewSecond = View.findDrawableById("SecondLabel") as Text;
        var secString = Lang.format("$1$", [clockTime.sec.format("%02d")]);
        viewSecond.setText(secString);

        var viewStep = View.findDrawableById("StepLabel") as Text;
        var info = ActivityMonitor.getInfo();
        var stepCount = info.steps;
        var stepString;
        // settingにより歩数表示か距離表示を切替
        centerLabelType = getApp().getProperty("CenterLabelType");
        switch(centerLabelType){
          case 0:
            stepString = Lang.format("$1$", [stepCount]);
            break;
          case 1:
            var df = info.distance.toFloat() / 100000.0;
            var d = (df).format(df > 10.0 ? "%.1f" : "%.2f");
            stepString = Lang.format("$1$km",[d]);
            break;
          default:
            stepString = "MUCCI";
        }
        viewStep.setText(stepString);

        var dayLabel = View.findDrawableById("DayLabel") as Text;
        var timeinfo = Time.Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var dow = timeinfo.day_of_week;
        var day = timeinfo.day;
        var dayString = Lang.format("$1$ $2$", [dow, day]);
        dayLabel.setText(dayString);

        var battLabel = View.findDrawableById("BattLabel") as Text;
        var battValue = System.getSystemStats().battery;
        battLabel.setText(battValue.format("%3.0f") + "%");

        // 停止判定(stepsが増加していない状態が60秒以上続いているか)
        // 初期設定
        if(memorySteps < 0){
          memorySteps = stepCount;
        }
        // 日付変更時リセット
        if(memorySteps > stepCount){
          memorySteps = stepCount;
        }
        if(memorySteps == stepCount){
          var dtime = Time.now().subtract(walkStopTime);
          if(dtime.value() >= _THRESHOLD_WALK_STOP){
            isWalking = false;
          }
        }else{
          isWalking = true;
          memorySteps = stepCount;
        }

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        shapes.draw(dc);
        if(isWalking){
          dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
          dc.drawText(140, 64, Graphics.FONT_XTINY, "MUCCI", Graphics.TEXT_JUSTIFY_LEFT);
          if(count == 0){
            bmpMucciLarge1.draw(dc);
            count = 1;
          }else{
            bmpMucciLarge2.draw(dc);
            count = 0;
          }
        }else{
          if(count == 0){
            bmpMucciSit1.draw(dc);
            count = 1;
          }else{
            bmpMucciSit2.draw(dc);
            count = 0;
          }
        }
        // バッテリーグラフィック表示
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(_battLeft, _battTop, battValue*27/100, 13);
        if(System.getSystemStats().charging){
          dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
          battCharge.draw(dc);
        }
        battOuter.draw(dc);
        // dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        // dc.drawText(104,120,fontDigits,"1234",Graphics.TEXT_JUSTIFY_CENTER);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }

}
