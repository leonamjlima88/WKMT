unit uCpfCnpj.ValueObject;

interface

type
  TCpfCnpjValueObject = class
  private
    FValue: String;
    class function CpfOrCnpjIsValid(ADocument: string): boolean;
    class function CpfIsValid(ACpf: string): boolean;
    class function CnpjIsValid(ACnpj: string): boolean;
    constructor Create(AValue: String);
  public
    class function Make(AValue: String): TCpfCnpjValueObject;
    function Value: String;
    function IsCpf: Boolean;
  end;

implementation

{ TCpfCnpjValueObject }

uses
  System.SysUtils,
  uHlp,
  uValueObject.Exception;

const
  CPF_LENGTH = 11;

class function TCpfCnpjValueObject.CnpjIsValid(ACnpj: string): boolean;
var
  D1: array[1..12] of byte;
  I, DF1, DF2, DF3, DF4, DF5, DF6, Resto1, Resto2, PrimeiroDigito,
  SegundoDigito: integer;
begin
  Result := true;

  if Length(ACnpj) = 14 then
  begin
    for I := 1 to 12 do
      D1[I] := StrToInt(ACnpj[I]);

    if Result then
    begin
      DF1 := 0;
      DF2 := 0;
      DF3 := 0;
      DF4 := 0;
      DF5 := 0;
      DF6 := 0;
      Resto1 := 0;
      Resto2 := 0;
      PrimeiroDigito := 0;
      SegundoDigito := 0;
      DF1 := 5*D1[1] + 4*D1[2] + 3*D1[3] + 2*D1[4] + 9*D1[5] + 8*D1[6] +
             7*D1[7] + 6*D1[8] + 5*D1[9] + 4*D1[10] + 3*D1[11] + 2*D1[12];
      DF2 := DF1 div 11;
      DF3 := DF2 * 11;
      Resto1 := DF1 - DF3;
      if (Resto1 = 0) or (Resto1 = 1) then
        PrimeiroDigito := 0
      else
        PrimeiroDigito := 11 - Resto1;

      DF4 := 6*D1[1] + 5*D1[2] + 4*D1[3] + 3*D1[4] + 2*D1[5] + 9*D1[6] +
             8*D1[7] + 7*D1[8] + 6*D1[9] + 5*D1[10] + 4*D1[11] + 3*D1[12] + 2*PrimeiroDigito;
      DF5 := DF4 div 11;
      DF6 := DF5 * 11;
      Resto2 := DF4 - DF6;
      if (Resto2 = 0) or (Resto2 = 1) then
        SegundoDigito := 0
      else
        SegundoDigito := 11 - Resto2;

      if (PrimeiroDigito <> StrToInt(ACnpj[13])) or
         (SegundoDigito <> StrToInt(ACnpj[14])) then
        Result := false;
    end;
  end else
    if Length(ACnpj) <> 0 then
      Result := false;
end;

class function TCpfCnpjValueObject.CpfIsValid(ACpf: string): boolean;
var
  D1: array[1..9] of byte;
  I, DF1, DF2, DF3, DF4, DF5, DF6, Resto1, Resto2, PrimeiroDigito,
  SegundoDigito: integer;
begin
  Result := true;

  if Length(ACpf) = CPF_LENGTH then
  begin
    for I := 1 to 9 do
      D1[I] := StrToInt(ACpf[I]);

    if Result then
    begin
      DF1 := 0;
      DF2 := 0;
      DF3 := 0;
      DF4 := 0;
      DF5 := 0;
      DF6 := 0;
      Resto1 := 0;
      Resto2 := 0;
      PrimeiroDigito := 0;
      SegundoDigito := 0;
      DF1 := 10*D1[1] + 9*D1[2] + 8*D1[3] + 7*D1[4] + 6*D1[5] + 5*D1[6] +
             4*D1[7] + 3*D1[8] + 2*D1[9];
      DF2 := DF1 div 11;
      DF3 := DF2 * 11;
      Resto1 := DF1 - DF3;
      if (Resto1 = 0) or (Resto1 = 1) then
        PrimeiroDigito := 0
      else
        PrimeiroDigito := 11 - Resto1;

      DF4 := 11*D1[1] + 10*D1[2] + 9*D1[3] + 8*D1[4] + 7*D1[5] + 6*D1[6] +
             5*D1[7] + 4*D1[8] + 3*D1[9] + 2*PrimeiroDigito;
      DF5 := DF4 div 11;
      DF6 := DF5 * 11;
      Resto2 := DF4 - DF6;

      if (Resto2 = 0) or (Resto2 = 1) then
        SegundoDigito := 0
      else
        SegundoDigito := 11 - Resto2;

      if (PrimeiroDigito <> StrToInt(ACpf[10])) or
         (SegundoDigito <> StrToInt(ACpf[11])) then
        Result := false;
    end;
  end else
    if Length(ACpf) <> 0 then
      Result := false;
End;

class function TCpfCnpjValueObject.CpfOrCnpjIsValid(ADocument: string): boolean;
begin
  case (ADocument.Length <= CPF_LENGTH) of
    True:  Result := CpfIsValid(ADocument);
    False: Result := CnpjIsValid(ADocument);
  end;
end;

constructor TCpfCnpjValueObject.Create(AValue: String);
begin
  inherited Create;
  FValue := AValue;
end;

function TCpfCnpjValueObject.IsCpf: Boolean;
begin
  Result := FValue.Length <= CPF_LENGTH;
end;

class function TCpfCnpjValueObject.Make(AValue: String): TCpfCnpjValueObject;
const
  LMSG = 'CPF/CNPJ [%s] é inválido.';
begin
  // Validar Campo
  AValue := THlp.OnlyNumbers(AValue);
  if not AValue.Trim.IsEmpty then
  begin
    if not CpfOrCnpjIsValid(AValue) then
      raise TValueObjectException.Create(Format(LMSG,[AValue]));
  end;
  Result := Self.Create(AValue);
end;

function TCpfCnpjValueObject.Value: String;
begin
  Result := FValue;
end;

end.
