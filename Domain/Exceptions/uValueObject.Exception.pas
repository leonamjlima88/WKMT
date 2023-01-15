unit uValueObject.Exception;

interface

uses
  System.SysUtils;

type
  TValueObjectException = class(Exception)
  private
    FInvalidValue: String;
  public
    constructor Create(const AMessage: String = 'Valor de entrada inválido'; const AValue: String = '');
  end;

implementation

{ TValueObjectException }

constructor TValueObjectException.Create(const AMessage, AValue: String);
begin
  inherited Create(AMessage);
  FInvalidValue := AValue;
end;

end.

