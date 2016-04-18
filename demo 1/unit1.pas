unit Unit1;

{$mode delphi}{$H+}

interface

uses
  {$ifdef MSWINDOWS}Windows, unGetWinVersion,
 {$endif}
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Menus,
  StdCtrls, Spin, ExtCtrls,

   ipl, opencv;
 const
    MAX_COUNT = 500;
type

  { TForm1 }

  TForm1 = class(TForm)
    Abort: TButton;
    VideoSettings: TButton;
    AutoInit: TButton;
    DeletePoints: TButton;
    Night: TButton;
    FrameRate: TFloatSpinEdit;
    Image1: TImage;
    Label1: TLabel;
    Timer1: TTimer;
    procedure AbortClick(Sender: TObject);
    procedure AutoInitClick(Sender: TObject);
    procedure DeletePointsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FrameRateChange(Sender: TObject);
    procedure NightClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

  TPointsArr = array[0..MAX_COUNT] of CvPoint2D32f;
  PPointsArr = ^TPointsArr;

var
  Form1: TForm1;
  image: pIplImage = nil;
grey: pIplImage = nil;
prev_grey: pIplImage = nil;
pyramid: pIplImage = nil;
prev_pyramid: pIplImage = nil;
swap_temp: pIplImage;

win_size: longint = 10;

points: array[0..1] of PPointsArr;
pointsRow1, pointsRow2: TPointsArr;
swap_points: PCvPoint2D32f ;
status: array [0..MAX_COUNT] of char;
count: longint = 0;
need_to_init: longint = 0;
night_mode: longint = 0;
flags: longint = 0;
add_remove_pt: longint = 0;
pt: CvPoint ;

nframe: integer;

i, k, c: longint;
{-----------------------}

capture: PCvCapture;
frame: PIplImage;
cframe: integer = 0;
selcam: longint = 0;
color: CvScalar;
bmp: TBitmap;

implementation

{$R *.lfm}

procedure main_cycle();
var
cs: CvSize;
eig, temp: PIplImage;
quality, min_distance, dx, dy: double;
i: integer;
newpoint: PCvPoint2D32f;
frame: PIplImage;

begin

         frame := cvQueryFrame( capture );
         cvNamedWindow(Pchar(Utf8ToAnsi('Kamera obrázek')), CV_WINDOW_KEEPRATIO);
         cvShowImage(Pchar(Utf8ToAnsi('Kamera obrázek')), frame );
         if not (assigned(frame)) then
            exit;


        if not (assigned(image )) then
        begin
            //* allocate all the buffers
            cs.width := frame.Width;
            cs.height := frame.Height;
            image := cvCreateImage( cs, 8, 3 );
            image.Origin := frame.origin;
            grey := cvCreateImage( cs, 8, 1 );
            prev_grey := cvCreateImage( cs, 8, 1 );
            pyramid := cvCreateImage( cs, 8, 1 );
            prev_pyramid := cvCreateImage( cs, 8, 1 );

            points[0] := @pointsRow1[0];
            points[1] := @pointsRow2[0];
            flags := 0;
        end;

        cvCopy( frame, image, 0 );
        cvCvtColor( image, grey, CV_BGR2GRAY );

        if( night_mode = 1) then
            cvZero( image );

        if( need_to_init = 1) then
        begin
            //* automatic initialization
            eig := cvCreateImage( cvGetSize(grey), 32, 1 );
            temp := cvCreateImage( cvGetSize(grey), 32, 1 );
            quality := 0.01;
            min_distance := 5.0;

            count := MAX_COUNT;
            cvGoodFeaturesToTrack( grey, eig, temp, @points[1][0], @count,
                                   quality, min_distance, 0, 3, 0, 0.04 );
            cvFindCornerSubPix( grey, @points[1][0], count,
                cvsize_(win_size, win_size), cvSize_(-1, -1),
                cvTermCriteria_(CV_TERMCRIT_ITER or CV_TERMCRIT_EPS, 20, 0.03));
            cvReleaseImage(eig );
            cvReleaseImage(temp );

            add_remove_pt := 0;
        end
        else
          if( count > 0 ) then
          begin
            cvCalcOpticalFlowPyrLK( prev_grey, grey, prev_pyramid, pyramid,
                @points[0][0], @points[1][0], count, cvSize_(win_size,win_size), 3, status, 0,
                cvTermCriteria_(CV_TERMCRIT_ITER or CV_TERMCRIT_EPS,20,0.03), flags );
            flags := flags or CV_LKFLOW_PYR_A_READY;

            // delete from points[] array the points vanished, i.e. the ones
            // with status=0
            k := 0;
            for i:=0 to count -1 do
            begin
                if( add_remove_pt = 1) then
                begin
                    dx := pt.x - points[1][i].x;
                    dy := pt.y - points[1][i].y;

                    if( dx*dx + dy*dy <= 25 ) then
                    begin
                        add_remove_pt := 0;
                        continue;
                    end;
                end;

                // retain only points with status<>0
                if (status[i] = #0) then
                    continue;

                cvCircle( image, cvPointFrom32f_(points[1][i]), 3, CV_RGB(0,255,0), -1, 8,0);
                cvLine(image, cvPointFrom32f_(points[0][i]),cvPointFrom32f_(points[1][i]), CV_RGB(255,0,0), 2);

                points[1][k] := points[1][i];
                inc(k);
            end;
            count := k;
        end;

        if (( add_remove_pt = 1) and (count < MAX_COUNT )) then
        begin
            points[1][count] := cvPointTo32f_(pt);
            inc(count);
            // newpoint -> points[1] + count - 1
            newpoint := @points[1][count-1];

            cvFindCornerSubPix( grey, newpoint, 1,
                cvSize_(win_size,win_size), cvSize_(-1,-1),
                cvTermCriteria_(CV_TERMCRIT_ITER or CV_TERMCRIT_EPS,20,0.030));
            add_remove_pt := 0;
        end;

        CV_SWAP( pointer(prev_grey), pointer(grey), pointer(swap_temp) );
        CV_SWAP( pointer(prev_pyramid), pointer(pyramid), pointer(swap_temp) );
        CV_SWAP( pointer(points[0]), pointer(points[1]), pointer(swap_points) );

        need_to_init := 0;

        {visualize the camera image in the window}
        IplImage2Bitmap(image, bmp);
        Form1.Image1.Picture.bitmap.assign(bmp);


end;

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
var
        nselCam, parm, n: longint;
        outc: Plongint;
begin

    try
   //     {$ifdef MSWINDOWS}  CorrectDSPackForVista; {$endif}
  //  capture := cvCaptureFromCAM(0); // exactly CV_CAP_DSHOW  =700 DirectShow (via videoInput)
   capture := cvCaptureFromFile(PChar('Terminator.The.Sarah.Connor.Chronicles.S02E01.HDTV.XviD-NoTV.mpg'));
    except
    	on ex : exception  do
    	begin
        	ShowMessage('Start capturing error - '+ex.message);
        	halt;
        end;
    end;
    if not(assigned(capture ))  then
    begin
        ShowMessage('Could not initialize capturing from camera!!');
        halt;
    end;

    cvSetCaptureProperty(capture, CV_CAP_PROP_FRAME_WIDTH, 800);
    cvSetCaptureProperty(capture, CV_CAP_PROP_FRAME_HEIGHT, 600);

    bmp := TBitmap.Create;


    //fsetup := tsetupfo.create(self);
    //fsetup.hide;
    //fsetup.brightness := round(cvGetCaptureProperty(capture, CV_CAP_PROP_BRIGHTNESS));
    //fsetup.contrast := round(cvGetCaptureProperty(capture, CV_CAP_PROP_CONTRAST));
    //fsetup.saturation := round(cvGetCaptureProperty(capture, CV_CAP_PROP_SATURATION));

    nframe := 0;
    timer1.enabled := true;

end;

procedure TForm1.AutoInitClick(Sender: TObject);
begin
   need_to_init := 1;
end;

procedure TForm1.AbortClick(Sender: TObject);
begin
            self.Destroy;
            halt;
end;

procedure TForm1.DeletePointsClick(Sender: TObject);
begin
   count := 0;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
     cvReleaseCapture( @capture );
end;

procedure TForm1.FrameRateChange(Sender: TObject);
begin
  Timer1.Interval :=  Round(1000/FrameRate.Value);
end;





procedure TForm1.NightClick(Sender: TObject);
begin
      night_mode := night_mode xor 1;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
         inc(nframe);
//        if (nframe>=seInterval.Value) then
        begin
                nframe := 1;
                main_cycle;
        end;
        application.processMessages;
end;



end.

