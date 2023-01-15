unit uEntityValidation.Exception;

interface

uses
  System.SysUtils;

type
  TEntityValidationException = class(Exception)
  private
    FInvalidValue: String;
  public
    constructor Create(const AMessage: String = 'Valor de entrada inválido'; const AValue: String = '');
  end;

implementation

{ TEntityValidationException }

constructor TEntityValidationException.Create(const AMessage, AValue: String);
begin
  inherited Create(AMessage);
  FInvalidValue := AValue;
end;

end.

