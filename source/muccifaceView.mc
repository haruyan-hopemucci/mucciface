import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class muccifaceView extends WatchUi.WatchFace {

    var count as Number;
    var bmpMucciL1;
    var bmpMucciL2;
    var bmpMucciR1;
    var bmpMucciR2;
    var bmpMucciLarge1;
    var bmpMucciLarge2;
    var bmpMucciSit1;
    var bmpMucciSit2;
    var shapes;
    var battOuter;
    var battCharge;
    var fontDigits;
    var memorySteps;
    var walkStopTime;
    var isWalking;
    var _THRESHOLD_WALK_STOP = 60;

    function initialize() {
        WatchFace.initialize();
        count = 0;
        bmpMucciL1 = new WatchUi.Bitmap({
          :rezId=>Rez.Drawables.BmpMucci1,
          :locX=>124,
          :locY=>96
        });
        bmpMucciL2 = new WatchUi.Bitmap({
          :rezId=>Rez.Drawables.BmpMucci2,
          :locX=>124,
          :locY=>96
        });
        bmpMucciLarge1 = new WatchUi.Bitmap({
          :rezId=>Rez.Drawables.BmpMucciL1,
          :locX=>124,
          :locY=>90
        });
        bmpMucciLarge2 = new WatchUi.Bitmap({
          :rezId=>Rez.Drawables.BmpMucciL2,
          :locX=>124,
          :locY=>90
        });
        // bmpMucciR1 = new WatchUi.Bitmap({
        //   :rezId=>Rez.Drawables.BmpMucci1,
        //   :locX=>160,
        //   :locY=>150
        // });
        // bmpMucciR2 = new WatchUi.Bitmap({
        //   :rezId=>Rez.Drawables.BmpMucci2,
        //   :locX=>160,
        //   :locY=>150
        // });
        shapes = new Rez.Drawables.shapes();
        battOuter = new Rez.Drawables.BattOuter();
        battCharge = new WatchUi.Bitmap({
          :rezId=>Rez.Drawables.BmpCharge,
          :locX=>132,
          :locY=>130
        });
        bmpMucciSit1 = new WatchUi.Bitmap({:rezId=>Rez.Drawables.BmpMucciSit1, :locX=>132, :locY=>69});
        bmpMucciSit2 = new WatchUi.Bitmap({:rezId=>Rez.Drawables.BmpMucciSit2, :locX=>132, :locY=>69});
        fontDigits = WatchUi.loadResource( Rez.Fonts.font_digits );
        memorySteps = -1;
        walkStopTime = Time.now();
        isWalking = true;
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
        View.findDrawableById("HLabel").setFont(fontDigits);
        View.findDrawableById("MLabel").setFont(fontDigits);
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {

    }

    function onPartialUpdate(dc as Dc){
      dc.setClip(80,170,44,34);
        var clockTime = System.getClockTime();
        var viewSecond = View.findDrawableById("SecondLabel") as Text;
        var secString = Lang.format("$1$", [clockTime.sec.format("%02d")]);
        viewSecond.setText(secString);
        View.onUpdate(dc);
      // dc.setClip(124,96,18,18);
      /*
      dc.setClip(124,90,22,28);
        if(count == 0){
          // bmpMucciL1.draw(dc);
          bmpMucciLarge1.draw(dc);
          bmpMucciSit1.draw(dc);
          // bmpMucciR1.draw(dc);
          count = 1;
        }else{
          // bmpMucciL2.draw(dc);
          bmpMucciLarge2.draw(dc);
          bmpMucciSit2.draw(dc);
          // bmpMucciR2.draw(dc);
          count = 0;
        }
      */
      if(isWalking){
        dc.setClip(124,90,22,28);
        if(count == 0){
          bmpMucciLarge1.draw(dc);
          count = 1;
        }else{
          bmpMucciLarge2.draw(dc);
          count = 0;
        }
      }else{
        dc.setClip(132,69,22,17);
        if(count == 0){
          bmpMucciSit1.draw(dc);
          count = 1;
        }else{
          bmpMucciSit2.draw(dc);
          count = 0;
        }
      }
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
      dc.setClip(0,0,208,208);
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
        var stepString = Lang.format("$1$", [stepCount]);
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
        dc.fillRectangle(126, 130, battValue*27/100, 13);
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
