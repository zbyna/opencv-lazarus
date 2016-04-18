unit Unit1;

{$mode objfpc}{$H+}



interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, OpenCV, IPL,LCLProc ;

type

  { TForm1 }

  TForm1 = class(TForm)
    imgGreyObr: TImage;
    imgColorObr: TImage;
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;
   colorObr, greyObr : PIplImage;
   colorObrM,greyObrM : PCvMat;
   bmColorObr,bmGreyObr :TBitmap;
implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
var
    value : Integer;

begin
  bmColorObr:= TBitmap.Create;
  colorObr:= cvLoadImage('DSCF1223.JPG');
  //ShowMessage(format('%d ',[colorObr^.WidthStep]));
  IplImage2Bitmap(colorObr,bmColorObr);
  imgColorObr.Canvas.StretchDraw(bounds(0,0,imgColorObr.Width,
                                            imgColorObr.Height),bmColorObr);

  bmGreyObr:= TBitmap.Create;
  greyObr := cvLoadImage('DSCF1223.JPG', CV_LOAD_IMAGE_GRAYSCALE);
  IplImage2Bitmap(greyObr,bmGreyObr);  // hází chybu viz. opencv.pas řádek 2270
     //assert((iplImg.Depth = 8) and (iplImg.NChannels = 3),
     //             'Not a 24 bit color iplImage!');
     // delphi port to pravděpodobně vyřešil viz.https://github.com/Laex/Delphi-OpenCV/blob/master/source/ocv.utils.pas
     // vyřešeno :-)) podívej se na vlastní fix hrdě ;-)
  imgGreyObr.Canvas.StretchDraw(bounds(0,0,imgGreyObr.Width,
                                           imgGreyObr.Height) ,bmGreyObr);

  cvNamedWindow(Pchar(Utf8ToAnsi('Šedivý obrázek')), CV_WINDOW_KEEPRATIO);
  cvShowImage(Pchar(Utf8ToAnsi('Šedivý obrázek')), greyObr );

  // z cvMat
  colorObrM:= cvLoadImageM('DSCF1223.JPG');
  cvNamedWindow(Pchar(Utf8ToAnsi('Obrázek z cvMat')),
                      CV_WINDOW_KEEPRATIO or CV_GUI_EXPANDED);
  cvShowImage(Pchar(Utf8ToAnsi('Obrázek z cvMat')), colorObrM );

  // v 64 bit. je width step 0 a nefunguje konverze IplImage2BitMap
  ShowMessage(format('%s %d'+LineEnding+'%s %d' +LineEnding+'%s %d' + LineEnding+
                     '-----------'+LineEnding+
                     '%s %d'+LineEnding+'%s %d' +LineEnding+'%s %d'+ LineEnding+
                     '-----------'+LineEnding+
                     '%s %d',
                     ['IplImage width step: ', colorObr^.WidthStep,
                      'Ipl image width: ',colorObr^.Width,
                      'Ipl image height',colorObr^.Height,
                      'mat width step: ', colorObrM^.step,
                      'mat cols: ',colorObrM^.cols,
                      'mat rows: ',colorObrM^.rows,
                      'size of PtrUint is: ',sizeof(PtrUInt)]));

  //ShowMessage(format('imgGreyObr: %d %d %d %d '+LineEnding +
  //                    'imgColorObr: %d %d %d %d ',
  //                    [imgGreyObr.ReadBounds.Top,
  //                    imgGreyObr.ReadBounds.Left,
  //                    imgGreyObr.ReadBounds.Bottom,
  //                    imgGreyObr.ReadBounds.Right,
  //                    imgColorObr.ReadBounds.Top,
  //                    imgColorObr.ReadBounds.Left,
  //                    imgColorObr.ReadBounds.Bottom,
  //                    imgColorObr.ReadBounds.Right]));

end;

end.

