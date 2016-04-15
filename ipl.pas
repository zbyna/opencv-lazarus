(*
               INTEL CORPORATION PROPRIETARY INFORMATION
This software is supplied under the terms of a license agreement or
nondisclosure agreement with Intel Corporation and may not be copied
or disclosed except in accordance with the terms of that agreement.
  Copyright (c) 1998-2000 Intel Corporation. All Rights Reserved.

From:
Purpose: IPL Common Header file
*)

unit IPL;

{$A+,Z+}

interface
{$ifdef FPC}{$mode delphi}{$endif}


uses
{$ifdef MSWINDOWS}  Windows;{$endif}
{$ifdef LINUX}    Linux;{$endif}

type
// Delphi XE2 fix
  CvChar = AnsiChar;
  PCvChar = PAnsiChar;
//--------------

  Float  = Single;
  PFloat = ^Float;
  P2PFloat = ^PFloat;
  Short  = SmallInt;
  PShort = ^Short;

  PDouble = ^Double;
  P2PDouble = ^PDouble;

  IPLStatus = Integer;

{---------------------------  Library Version  ----------------------------}
type
  PIPLLibVersion = ^TIPLLibVersion;
  TIPLLibVersion = record
    Major           : Integer;       // e.g. 1
    Minor           : Integer;       // e.g. 00
    Build           : Integer;       // e.g. 01
    Name            : PCvChar;         // e.g. "ipl6l.lib","iplm5.dll"
    Version         : PCvChar;         // e.g. "v1.00"
    InternalVersion : PCvChar;         // e.g. "[1.00.01, 07/25/96]"
    BuildDate       : PCvChar;         // e.g. "Jun 1 96"
    CallConv        : PCvChar;         // e.g. "DLL"
  end;
{==========================================================================
      Section: Misc macros and definitions
 ==========================================================================}

function IPL_DegToRad(Deg : Extended) : Extended;
function IPLsDegToRad(Deg : Float)    : Float;
function IPLdDegToRad(Deg : Double)   : Double;

const
  IPL_EPS  = 1.0E-12;
  IPL_PI   = 3.14159265358979324;
  IPL_2PI  = 6.28318530717958648;
  IPL_PI_2 = 1.57079632679489662;
  IPL_PI_4 = 0.785398163397448310;

{----------------------  Code for channel sequence  -----------------------}
const
  IPL_CSEQ_G     = $00000047;      //* "G"    */
  IPL_CSEQ_GRAY  = $59415247;      //* "GRAY" */
  IPL_CSEQ_BGR   = $00524742;      //* "BGR"  */
  IPL_CSEQ_BGRA  = $41524742;      //* "BGRA" */
  IPL_CSEQ_RGB   = $00424752;      //* "RGB"  */
  IPL_CSEQ_RGBA  = $41424752;      //* "RGBA" */

  {==== IPLibrary Definitions ===================================================}
  IPL_DEPTH_SIGN = Integer($80000000);
  IPL_DEPTH_MASK = $7FFFFFFF;

  IPL_DEPTH_1U   =  1;
  IPL_DEPTH_8U   =  8;
  IPL_DEPTH_16U  = 16;
  IPL_DEPTH_32F  = 32;

  IPL_DEPTH_8S   = IPL_DEPTH_SIGN or  8;
  IPL_DEPTH_16S  = IPL_DEPTH_SIGN or 16;
  IPL_DEPTH_32S  = IPL_DEPTH_SIGN or 32;

  IPL_DATA_ORDER_PIXEL = 0;
  IPL_DATA_ORDER_PLANE = 1;

  IPL_ORIGIN_TL  = 0;
  IPL_ORIGIN_BL  = 1;

  IPL_ALIGN_4BYTES  =  4;
  IPL_ALIGN_8BYTES  =  8;
  IPL_ALIGN_16BYTES = 16;
  IPL_ALIGN_32BYTES = 32;

  IPL_ALIGN_DWORD   = IPL_ALIGN_4BYTES;
  IPL_ALIGN_QWORD   = IPL_ALIGN_8BYTES;

  IPL_GET_TILE_TO_READ  = 1;
  IPL_GET_TILE_TO_WRITE = 2;
  IPL_RELEASE_TILE      = 4;

  IPL_LUT_LOOKUP = 0;
  IPL_LUT_INTER  = 1;

(*
{==== Code for channel sequence ============================================}
  IPL_CSEQ_G     = $00000047;      //* "G"    */
  IPL_CSEQ_GRAY  = $59415247;      //* "GRAY" */
  IPL_CSEQ_BGR   = $00524742;      //* "BGR"  */
  IPL_CSEQ_BGRA  = $41524742;      //* "BGRA" */
  IPL_CSEQ_RGB   = $00424752;      //* "RGB"  */
  IPL_CSEQ_RGBA  = $41424752;      //* "RGBA" */
*)

{==== Common Types =========================================================}
type


  PIplImage = ^TIplImage; // defined later
  P2PIplImage = ^PIplImage;
  TIplCallBack = procedure(const Img    : PIplImage;
                                 XIndex : Integer;
                                 YIndex : Integer;
                                 Mode   : Integer); stdcall;
{
   Purpose:        Type of functions for access to external manager of tile
   Parameters:
     Img           - header provided for the parent image
     XIndex,YIndex - indices of the requested tile. They refer to the tile
                     number not pixel number, and count from the origin at (0,0)
     Mode          - one of the following:
        IPL_GET_TILE_TO_READ  - get a tile for reading;
                                tile data is returned in "img->tileInfo->tileData",
                                and must not be changed
        IPL_GET_TILE_TO_WRITE - get a tile for writing;
                                tile data is returned in "img->tileInfo->tileData"
                                and may be changed;
                                changes will be reflected in the image
        IPL_RELEASE_TILE      - release tile; commit writes
   Notes: Memory pointers provided by a get function will not be used after the
          corresponding release function has been called.
}

  PIplTileInfo = ^TIplTileInfo;
  TIplTileInfo = record
    CallBack : TIplCallBack; // callback function
    Id       : Pointer;      // additional identification field
    TileData : PByte;        // pointer on tile data
    Width    : Integer;      // width of tile
    Height   : Integer;      // height of tile
  end;

  PIplROI = ^TIplROI;
  TIplROI = record
    Coi     : Integer;
    XOffset : Integer;
    YOffset : Integer;
    Width   : Integer;
    Height  : Integer;
  end;

  TIplImage = record
    NSize           : Integer;                 // size of iplImage struct
    ID              : Integer;                 // version
    NChannels       : Integer;
    AlphaChannel    : Integer;
    Depth           : Integer;                 // pixel depth in bits
    ColorModel      : array [0..3] of CvChar;
    ChannelSeq      : array [0..3] of CvChar;
    DataOrder       : Integer;
    Origin          : Integer;
    Align           : Integer;                 // 4 or 8 byte align
    Width           : Integer;
    Height          : Integer;
    Roi             : PIplROI;
    MaskROI         : PIplImage;               // poiner to maskROI if any
    ImageId         : Pointer;                 // use of the application
    TileInfo        : PIplTileInfo;            // contains information on tiling
    ImageSize       : Integer;                 // useful size in bytes
    ImageData       : PByte;                   // pointer to aligned image
    WidthStep       : Integer;                 // size of aligned line in bytes
    BorderMode      : array [0..3] of Integer;
    BorderConst     : array [0..3] of Integer;
    ImageDataOrigin : PByte;                   // ptr to full, nonaligned image
  end;

  PIplLUT = ^TIplLUT;
  TIplLUT = record
    Num             : Integer;
    Key             : PInteger;
    Value           : PInteger;
    Factor          : PInteger;
    InterpolateType : Integer;
  end;

  PIplColorTwist = ^TIplColorTwist;
  TIplColorTwist = record
    Data         : array [0..15] of Integer;
    ScalingValue : Integer;
  end;

  PIplConvKernel = ^TIplConvKernel;
  P2PIplConvKernel = ^PIplConvKernel;
  TIplConvKernel = record
    NCols   : Integer;
    NRows   : Integer;
    AnchorX : Integer;
    AnchorY : Integer;
    Values  : PInteger;
    NShiftR : Integer;
  end;

  PIplConvKernelFP = ^TIplConvKernelFP;
  TIplConvKernelFP = record
    NCols   : Integer;
    NRows   : Integer;
    AnchorX : Integer;
    AnchorY : Integer;
    Values  : PFloat;
  end;

  TIplFilter = (
    IPL_PREWITT_3x3_V,
    IPL_PREWITT_3x3_H,
    IPL_SOBEL_3x3_V,   //* vertical */
    IPL_SOBEL_3x3_H,   //* horizontal */
    IPL_LAPLACIAN_3x3,
    IPL_LAPLACIAN_5x5,
    IPL_GAUSSIAN_3x3,
    IPL_GAUSSIAN_5x5,
    IPL_HIPASS_3x3,
    IPL_HIPASS_5x5,
    IPL_SHARPEN_3x3);

  POwnMoment = ^TOwnMoment;
  TOwnMoment = record // spatial moment structure:
    Scale : Double;   // value to scale (m,n)th moment
    Value : Double;   // spatial (m,n)th moment
  end;

// spatial moments array
  PIplMomentState = ^TIplMomentState;
  TIplMomentState = array [0..3,0..3] of TOwnMoment;

{==========================================================================
      Section: Wavelet transform constants and types.
 =========================================================================}


{--------------------  Types of wavelet transforms.  ---------------------}
  TIplWtType = (
    IPL_WT_HAAR,
    IPL_WT_DAUBLET,
    IPL_WT_SYMMLET,
    IPL_WT_COIFLET,
    IPL_WT_VAIDYANATHAN,
    IPL_WT_BSPLINE,
    IPL_WT_BSPLINEDUAL,
    IPL_WT_LINSPLINE,
    IPL_WT_QUADSPLINE,
    IPL_WT_TYPE_UNKNOWN
  );

{-----------------------  Filters symmetry type.  ------------------------}
  TIplWtFiltSymm = (
    IPL_WT_SYMMETRIC,
    IPL_WT_ANTISYMMETRIC,
    IPL_WT_ASYMMETRIC,
    IPL_WT_SYMM_UNKNOWN
  );

{---------------------  Filter bank orthogonality.  ----------------------}
  TIplWtOrthType = (
    IPL_WT_ORTHOGONAL,
    IPL_WT_BIORTHOGONAL,
    IPL_WT_NOORTHOGONAL,
    IPL_WT_ORTH_UNKNOWN
  );

{--------------------------  Filter structure  ---------------------------}
  PIplWtFilter = ^TIplWtFilter;
  TIplWtFilter = record
    Taps     : PFloat;         // filter taps
    Len      : Integer;        // length of filter
    Offset   : Integer;        // offset of filter
    Symmetry : TIplWtFiltSymm; // filter symmetry property
  end;

{---------------  Wavelet functions interchange structure  ---------------}
  PIplWtKernel = ^TIplWtKernel;
  TIplWtKernel = record
    WtType      : TIplWtType;     // type of wavelet transform
    Par1        : Integer;        // first param.  (transform order)
    Par2        : Integer;        // second param. (only for biorth. tr.)
    Orth        : TIplWtOrthType; // orthogonality property
    FiltDecLow  : TIplWtFilter;   // low-pass decomposition filter
    FiltDecHigh : TIplWtFilter;   // high-pass decomposition filter
    FiltRecLow  : TIplWtFilter;   // low-pass reconstruction filter
    FiltRecHigh : TIplWtFilter;   // high-pass reconstruction filter
  end;

implementation

const
  iplDLL = 'IPL.DLL';

function IPL_DegToRad(Deg : Extended) : Extended;
begin
  Result := (Deg)/180.0 * IPL_PI;
end;

function IPLsDegToRad(Deg : Float)    : Float;
begin
  Result := (Deg)/180.0 * IPL_PI;
end;

function IPLdDegToRad(Deg : Double)   : Double;
begin
  Result := (Deg)/180.0 * IPL_PI;
end;

end.


