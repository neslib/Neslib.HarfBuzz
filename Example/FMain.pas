unit FMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Memo.Types,
  FMX.ScrollBox, FMX.Memo, FMX.StdCtrls, FMX.Edit, FMX.Layouts,
  FMX.Controls.Presentation;

type
  TFormMain = class(TForm)
    ToolBar: TToolBar;
    LayoutShape: TLayout;
    EditText: TEdit;
    ButtonShape: TButton;
    MemoResults: TMemo;
    procedure ButtonShapeClick(Sender: TObject);
    procedure EditTextChangeTracking(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;

implementation

uses
  Neslib.HarfBuzz;

{$R *.fmx}
{$R 'Font.res'}

procedure TFormMain.ButtonShapeClick(Sender: TObject);
begin
  MemoResults.Lines.Clear;
  var Text := EditText.Text.Trim;
  if (Text = '') then
    Exit;

  { 1. Create a buffer and put your text in it. }
  var Buf := hb_buffer_create;
  hb_buffer_add_utf16(Buf, PChar(Text), Length(Text), 0, -1);

  { 2. Set the script, language and direction of the buffer. }

  // If you know the direction, script, and language
//  hb_buffer_set_direction(Buf, HB_DIRECTION_LTR);
//  hb_buffer_set_script(Buf, HB_SCRIPT_LATIN);
//  hb_buffer_set_language(Buf, hb_language_from_string('en', -1));

  // If you don't know the direction, script, and language
  hb_buffer_guess_segment_properties(Buf);

  { 3. Create a face and a font from a font resource. }
  var FontData: TBytes;
  var Stream := TResourceStream.Create(HInstance, 'BASKERVVILLE_REGULAR', RT_RCDATA);
  try
    SetLength(FontData, Stream.Size);
    Stream.ReadBuffer(FontData, Length(FontData));
  finally
    Stream.Free;
  end;

  var Blob := hb_blob_create(FontData, Length(FontData),
    HB_MEMORY_MODE_READONLY, nil, nil);

  var Face := hb_face_create(Blob, 0);
  var Font := hb_font_create(Face);

  { 4. Shape! }
  hb_shape(Font, Buf, nil, 0);

  { 5. Get the glyph and position information. }
  var GlyphCount: Integer;
  var GlyphInfo := hb_buffer_get_glyph_infos(Buf, @GlyphCount);
  var GlyphPos := hb_buffer_get_glyph_positions(Buf, @GlyphCount);

  { 6. Iterate over each glyph. }
  var CursorX: hb_position_t := 0;
  var CursorY: hb_position_t := 0;
  for var I := 0 to GlyphCount - 1 do
  begin
    var ClusterSize := 1;
    if (I < (GlyphCount - 1)) then
    begin
      var NextGlyphInfo := GlyphInfo;
      Inc(NextGlyphInfo);
      ClusterSize := NextGlyphInfo.cluster - GlyphInfo.cluster;
    end;
    var ClusterText := Text.Substring(GlyphInfo.cluster, ClusterSize);

    MemoResults.Lines.Add(Format('Codepoint: %d, Cluster: %d (''%s''), Pos: (%d, %d), Offset: (%d, %d), Advance: (%d, %d)',
      [GlyphInfo.codepoint, GlyphInfo.cluster, ClusterText, CursorX, CursorY,
       GlyphPos.x_offset, GlyphPos.y_offset, GlyphPos.x_advance, GlyphPos.y_advance]));

    Inc(CursorX, GlyphPos.x_advance);
    Inc(CursorY, GlyphPos.y_advance);
    Inc(GlyphInfo);
    Inc(GlyphPos);
  end;

  { 7. Tidy up }
  hb_font_destroy(Font);
  hb_face_destroy(Face);
  hb_blob_destroy(Blob);
  hb_buffer_destroy(Buf);
end;

procedure TFormMain.EditTextChangeTracking(Sender: TObject);
begin
  ButtonShape.Enabled := (EditText.Text.Trim <> '');
end;

end.
