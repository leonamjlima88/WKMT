// Exemplo de uso
//procedure TForm1.Button1Click(Sender: TObject);
//var
//  s: IShared<TStringList>;
//begin
//  s := Shared<TStringList>.Make;
//  s.Add('teste');
//  showmessage(s.Count.ToString);
//end;

unit uSmartPointer;

interface

uses
  System.Rtti,
  TypInfo,
  Generics.Collections,
  SysUtils;

type
  PObject = ^TObject;

  /// <summary>
  ///   Represents a logical predicate.
  /// </summary>
  /// <param name="arg">
  ///   the value needs to be determined.
  /// </param>
  /// <returns>
  ///   Returns <c>True</c> if the value was accepted, otherwise, returns <c>
  ///   False</c>.
  /// </returns>
  /// <remarks>
  ///   <note type="tip">
  ///     This type redefined the <see cref="SysUtils|TPredicate`1">
  ///     SysUtils.TPredicate&lt;T&gt;</see> type with a const parameter.
  ///   </note>
  /// </remarks>
  /// <seealso cref="Spring.DesignPatterns|ISpecification&lt;T&gt;" />
  {$M+}
  TPredicate<T> = reference to function(const arg: T): Boolean;
  {$M-}

  /// <summary>
  ///   Represents an anonymous method that has a single parameter and does not
  ///   return a value.
  /// </summary>
  /// <seealso cref="TActionProc&lt;T&gt;" />
  /// <seealso cref="TActionMethod&lt;T&gt;" />
  {$M+}
  TAction<T> = reference to procedure(const arg: T);

  TAction<T1, T2> = reference to procedure(const arg1: T1; const arg2: T2);

  TAction<T1, T2, T3> = reference to procedure(const arg1: T1; const arg2: T2; const arg3: T3);

  TAction<T1, T2, T3, T4> = reference to procedure(const arg1: T1; const arg2: T2; const arg3: T3; const arg4: T4);
  {$M-}

  /// <summary>
  ///   Represents a procedure that has a single parameter and does not return
  ///   a value.
  /// </summary>
  /// <seealso cref="TAction&lt;T&gt;" />
  /// <seealso cref="TActionMethod&lt;T&gt;" />
  TActionProc<T> = procedure(const arg: T);

  /// <summary>
  ///   Represents a instance method that has a single parameter and does not
  ///   return a value.
  /// </summary>
  /// <seealso cref="TAction&lt;T&gt;" />
  /// <seealso cref="TActionProc&lt;T&gt;" />
  TActionMethod<T> = procedure(const arg: T) of object;

  /// <summary>
  ///   Represents a anonymous method that has the same signature as
  ///   TNotifyEvent.
  /// </summary>
  {$M+}
  TNotifyProc = reference to procedure(Sender: TObject);
  {$M-}

  /// <summary>
  ///   An event type like TNotifyEvent that also has a generic item parameter.
  /// </summary>
  TNotifyEvent<T> = procedure(Sender: TObject; const item: T) of object;

  ENotSupportedException = SysUtils.ENotSupportedException;

  IShared<T> = reference to function: T;

  Shared<T> = record
  strict private
    fValue: T;
    fFinalizer: IInterface;
    class function GetMake: IShared<T>; static;
  public
    class operator Implicit(const value: IShared<T>): Shared<T>;
    class operator Implicit(const value: Shared<T>): IShared<T>;
    class operator Implicit(const value: Shared<T>): T; {$IFNDEF DELPHIXE4}inline;{$ENDIF}
    class operator Implicit(const value: T): Shared<T>;
    property Value: T read fValue;

    class property Make: IShared<T> read GetMake;
    class function New: IShared<T>; static; deprecated 'use Shared<T>.Make';
  end;

  TType = class
  private
    class var fContext: TRttiContext;
  public
    class constructor Create;
    class destructor Destroy;

    class function HasWeakRef<T>: Boolean; inline; static;
    class function IsManaged<T>: Boolean; inline; static;
    class function Kind<T>: TTypeKind; inline; static;

    class function GetType<T>: TRttiType; overload; static; inline;
    class function GetType(typeInfo: PTypeInfo): TRttiType; overload; static;
    class function GetType(classType: TClass): TRttiInstanceType; overload; static;

    class property Context: TRttiContext read fContext;
  end;

  Shared = record
  private type
    PObjectFinalizer = ^TObjectFinalizer;
    TObjectFinalizer = record
    private
      Vtable: Pointer;
      RefCount: Integer;
      Value: TObject;
      function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
      function _AddRef: Integer; stdcall;
      function _Release: Integer; stdcall;
      function Invoke: TObject;
    public
      class function Create(typeInfo: PTypeInfo): PObjectFinalizer; overload; static;
      class function Create(const value: TObject): PObjectFinalizer; overload; static;
    end;

    TRecordFinalizer = class(TInterfacedObject, IShared<Pointer>)
    private
      fValue: Pointer;
      fTypeInfo: PTypeInfo;
      function Invoke: Pointer;
    public
      constructor Create(typeInfo: PTypeInfo); overload;
      constructor Create(const value: Pointer; typeInfo: PTypeInfo); overload;
      destructor Destroy; override;
    end;

    THandleFinalizer<T> = class(TInterfacedObject, IShared<T>)
    private
      fValue: T;
      fFinalizer: TAction<T>;
      function Invoke: T;
    public
      constructor Create(const value: T; finalizer: TAction<T>);
      destructor Destroy; override;
    end;

  const
    ObjectFinalizerVtable: array[0..3] of Pointer =
    (
      @TObjectFinalizer.QueryInterface,
      @TObjectFinalizer._AddRef,
      @TObjectFinalizer._Release,
      @TObjectFinalizer.Invoke
    );
  private
    class procedure Make(const value: TObject; var result: PObjectFinalizer); overload; static; inline;
  public
    class function Make<T>(const value: T): IShared<T>; overload; static;
    class function Make<T>(const value: T; const finalizer: TAction<T>): IShared<T>; overload; static;

    class function New<T>(const value: T): IShared<T>; overload; static; deprecated 'use Shared.Make';
    class function New<T>(const value: T; const finalizer: TAction<T>): IShared<T>; overload; static; deprecated 'use Shared.Make';
  end;

  IObjectActivator = interface
    ['{CE05FB89-3467-449E-81EA-A5AEECAB7BB8}']
    function CreateInstance: TValue;
  end;

  TConstructor = function(InstanceOrVMT: Pointer; Alloc: ShortInt = 1): Pointer;

  TActivator = record
  private
    class var ConstructorCache: TDictionary<PTypeInfo,TConstructor>;
    class function FindConstructor(const classType: TRttiInstanceType;
      const arguments: array of TValue): TRttiMethod; overload; static;
    class procedure RaiseNoConstructorFound(classType: TClass); static;
  public
    class constructor Create;
    class destructor Destroy;

    class procedure ClearCache; static;

    class function CreateInstance(const classType: TRttiInstanceType): TValue; overload; static;
    class function CreateInstance(const classType: TRttiInstanceType;
      const arguments: array of TValue): TValue; overload; static;
    class function CreateInstance(const classType: TRttiInstanceType;
      const constructorMethod: TRttiMethod; const arguments: array of TValue): TValue; overload; static;

    class function CreateInstance(typeInfo: PTypeInfo): TObject; overload; static; inline;
    class function CreateInstance(const typeName: string): TObject; overload; static; inline;
    class function CreateInstance(const typeName: string;
      const arguments: array of TValue): TObject; overload; static;

    class function CreateInstance(classType: TClass): TObject; overload; static;
    class function CreateInstance(classType: TClass;
      const arguments: array of TValue): TObject; overload; static;

    class function CreateInstance<T: class>: T; overload; static; inline;
    class function CreateInstance<T: class>(
      const arguments: array of TValue): T; overload; static;

    class function FindConstructor(classType: TClass): TConstructor; overload; static;
  end;

  /// <summary>
  ///   Returns the size that is needed in order to pass an argument of the given
  ///   type.
  /// </summary>
  /// <remarks>
  ///   While in most cases the result is equal to the actual type size for short
  ///   strings it always returns SizeOf(Pointer) as short strings are always
  ///   passed as pointer.
  /// </remarks>
  function GetTypeSize(typeInfo: PTypeInfo): Integer;

  /// <summary>
  ///   Returns the size of the passed set type
  /// </summary>
  function GetSetSize(typeInfo: PTypeInfo): Integer;


implementation

{ Shared<T> }

class function Shared<T>.GetMake: IShared<T>;
begin
  case TType.Kind<T> of
    tkClass: IShared<TObject>(Result) := IShared<TObject>(Shared.TObjectFinalizer.Create(TypeInfo(T)));
    tkPointer: IShared<Pointer>(Result) := Shared.TRecordFinalizer.Create(TypeInfo(T));
  end;
end;

class operator Shared<T>.Implicit(const value: Shared<T>): IShared<T>;
begin
  Result := IShared<T>(value.fFinalizer);
end;

class operator Shared<T>.Implicit(const value: IShared<T>): Shared<T>;
begin
  Result.fValue := value();
  IShared<T>(Result.fFinalizer) := value;
end;

class operator Shared<T>.Implicit(const value: T): Shared<T>;
begin
  Result.fValue := value;
  case TType.Kind<T> of
{$IFNDEF AUTOREFCOUNT}
    tkClass:
      if PPointer(@value)^ = nil then
        Result.fFinalizer := nil
      else
        Result.fFinalizer := IInterface(Shared.TObjectFinalizer.Create(PObject(@value)^));
{$ENDIF}
    tkPointer:
      if PPointer(@value)^ = nil then
        Result.fFinalizer := nil
      else
        Result.fFinalizer := Shared.TRecordFinalizer.Create(PPointer(@value)^, TypeInfo(T));
  end;
end;

class operator Shared<T>.Implicit(const value: Shared<T>): T;
begin
  Result := value.fValue;
end;

class function Shared<T>.New: IShared<T>;
begin
  Result := GetMake();
end;

{ Shared }

class procedure Shared.Make(const value: TObject; var result: PObjectFinalizer);
begin
  if Assigned(result) and (AtomicDecrement(result.RefCount) = 0) then
    result.Value.Free
  else
  begin
    GetMem(result, SizeOf(TObjectFinalizer));
    result.Vtable := @Shared.ObjectFinalizerVtable;
  end;
  result.RefCount := 1;
  result.Value := value;
end;

class function Shared.Make<T>(const value: T): IShared<T>;
begin
  case TType.Kind<T> of
    tkClass: Make(PObject(@value)^, PObjectFinalizer(Result));
    tkPointer: IShared<Pointer>(Result) := Shared.TRecordFinalizer.Create(PPointer(@value)^, TypeInfo(T));
  end;
end;

class function Shared.Make<T>(const value: T; const finalizer: TAction<T>): IShared<T>;
begin
  Result := THandleFinalizer<T>.Create(value, finalizer);
end;

class function Shared.New<T>(const value: T): IShared<T>;
begin
  Result := Make<T>(value);
end;

class function Shared.New<T>(const value: T; const finalizer: TAction<T>): IShared<T>;
begin
  Result := Make<T>(value, finalizer);
end;

{ TType }

class constructor TType.Create;
begin
  fContext := TRttiContext.Create;
end;

class destructor TType.Destroy;
begin
  fContext.Free;
end;

class function TType.GetType(typeInfo: PTypeInfo): TRttiType;
begin
  Result := fContext.GetType(typeInfo);
end;

class function TType.GetType(classType: TClass): TRttiInstanceType;
begin
  Result := TRttiInstanceType(fContext.GetType(classType));
end;

class function TType.GetType<T>: TRttiType;
begin
  Result := fContext.GetType(TypeInfo(T));
end;

class function TType.HasWeakRef<T>: Boolean;
begin
{$IFDEF DELPHIXE7_UP}
  Result := System.HasWeakRef(T);
{$ELSE}
  {$IFDEF WEAKREF}
  Result := TypInfo.HasWeakRef(TypeInfo(T));
  {$ELSE}
  Result := False;
  {$ENDIF}
{$ENDIF}
end;

class function TType.IsManaged<T>: Boolean;
begin
  Result := System.IsManagedType(T);
end;

class function TType.Kind<T>: TTypeKind;
{$IFDEF DELPHIXE7_UP}
begin
  Result := System.GetTypeKind(T);
{$ELSE}
var
  typeInfo: PTypeInfo;
begin
  typeInfo := System.TypeInfo(T);
  if typeInfo = nil then
    Exit(tkUnknown);
  Result := typeInfo.Kind;
{$ENDIF}
end;

{ Shared.TObjectFinalizer }

class function Shared.TObjectFinalizer.Create(typeInfo: PTypeInfo): PObjectFinalizer;
begin
  Result := Create(TActivator.CreateInstance(typeInfo.TypeData.ClassType));
end;

class function Shared.TObjectFinalizer.Create(const value: TObject): PObjectFinalizer;
begin
  GetMem(Result, SizeOf(TObjectFinalizer));
  Result.Vtable := @Shared.ObjectFinalizerVtable;
  Result.RefCount := 0;
  Result.Value := value;
end;

function Shared.TObjectFinalizer.Invoke: TObject;
begin
  Result := Value;
end;

function Shared.TObjectFinalizer.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  Result := E_NOINTERFACE;
end;

function Shared.TObjectFinalizer._AddRef: Integer;
begin
  Result := AtomicIncrement(RefCount);
end;

function Shared.TObjectFinalizer._Release: Integer;
begin
  Result := AtomicDecrement(RefCount);
  if Result = 0 then
  begin
    Value.Free;
    FreeMem(@Self);
  end;
end;

{ Shared.TRecordFinalizer }

constructor Shared.TRecordFinalizer.Create(typeInfo: PTypeInfo);
begin
  inherited Create;
  fTypeInfo := typeInfo.TypeData.RefType^;
  fValue := AllocMem(GetTypeSize(fTypeInfo));
end;

constructor Shared.TRecordFinalizer.Create(const value: Pointer; typeInfo: PTypeInfo);
begin
  inherited Create;
  fTypeInfo := typeInfo.TypeData.RefType^;
  fValue := value;
end;

destructor Shared.TRecordFinalizer.Destroy;
begin
  FinalizeArray(fValue, fTypeInfo, 1);
  FillChar(fValue^, fTypeInfo.TypeData.RecSize, 0);
  FreeMem(fValue);
  inherited;
end;

function Shared.TRecordFinalizer.Invoke: Pointer;
begin
  Result := fValue;
end;

{ Shared.THandleFinalizer<T> }

constructor Shared.THandleFinalizer<T>.Create(const value: T; finalizer: TAction<T>);
begin
  inherited Create;
  fValue := value;
  fFinalizer := finalizer;
end;

destructor Shared.THandleFinalizer<T>.Destroy;
begin
  fFinalizer(fValue);
  inherited;
end;

function Shared.THandleFinalizer<T>.Invoke: T;
begin
  Result := fValue;
end;

{ TActivator }

class procedure TActivator.ClearCache;
begin
  ConstructorCache.Clear;
end;

class constructor TActivator.Create;
begin
  ConstructorCache := TDictionary<PTypeInfo,TConstructor>.Create;
end;

class function TActivator.CreateInstance(typeInfo: PTypeInfo): TObject;
begin
  Result := CreateInstance(typeInfo.TypeData.ClassType);
end;

class function TActivator.CreateInstance(classType: TClass; const arguments: array of TValue): TObject;
var
  ctor: TRttiMethod;
begin
  if Length(arguments) = 0 then
    Exit(CreateInstance(classType));
  ctor := FindConstructor(TType.GetType(classType), arguments);
  if not Assigned(ctor) then
    RaiseNoConstructorFound(classType);
  Result := ctor.Invoke(classType, arguments).AsObject;
end;

class function TActivator.CreateInstance(classType: TClass): TObject;
var
  ctor: TConstructor;
begin
  ctor := FindConstructor(classType);
  Result := ctor(classType);
end;


class function TActivator.CreateInstance(const typeName: string): TObject;
begin
  Result := CreateInstance(typeName, []);
end;

class function TActivator.CreateInstance(const typeName: string; const arguments: array of TValue): TObject;
var
  rttiType: TRttiType;
begin
  rttiType := TType.Context.FindType(typeName);
  Result := CreateInstance(TRttiInstanceType(rttiType), arguments).AsObject;
end;

class function TActivator.CreateInstance(const classType: TRttiInstanceType): TValue;
begin
  Result := CreateInstance(classType, []);
end;

class function TActivator.CreateInstance(const classType: TRttiInstanceType; const arguments: array of TValue): TValue;
var
  method: TRttiMethod;
begin
  method := FindConstructor(classType, arguments);
  if not Assigned(method) then
    RaiseNoConstructorFound(classType.MetaclassType);
  Result := CreateInstance(classType, method, arguments)
end;

class function TActivator.CreateInstance(const classType: TRttiInstanceType; const constructorMethod: TRttiMethod; const arguments: array of TValue): TValue;
begin
  Result := constructorMethod.Invoke(classType.MetaclassType, arguments);
end;

class function TActivator.CreateInstance<T>(const arguments: array of TValue): T;
begin
  Result := T(CreateInstance(TClass(T), arguments));
end;

class function TActivator.CreateInstance<T>: T;
begin
  Result := T(CreateInstance(TClass(T)));
end;

class destructor TActivator.Destroy;
begin
  ConstructorCache.Free;
end;

class function TActivator.FindConstructor(classType: TClass): TConstructor;
var
  classInfo: PTypeInfo;
  method: TRttiMethod;
begin
  Assert(Assigned(classType));
  classInfo := classType.ClassInfo;
  if ConstructorCache.TryGetValue(classInfo, Result) then
    Exit;

  for method in TType.GetType(classInfo).GetMethods do
  begin
    if not method.IsConstructor then
      Continue;

    if Length(method.GetParameters) = 0 then
    begin
      Result := method.CodeAddress;
      ConstructorCache.AddOrSetValue(classInfo, Result);
      Exit;
    end;
  end;
  Result := nil;
end;

class function TActivator.FindConstructor(const classType: TRttiInstanceType;
  const arguments: array of TValue): TRttiMethod;

  function Assignable(const params: TArray<TRttiParameter>;
    const args: array of TValue): Boolean;
  var
    i: Integer;
    v: TValue;
  begin
    Result := Length(params) = Length(args);
    if Result then
      for i := Low(args) to High(args) do
        if not args[i].TryCast(params[i].paramType.Handle, v) then
          Exit(False);
  end;

var
  method: TRttiMethod;
begin
  for method in classType.GetMethods do
  begin
    if not method.IsConstructor then
      Continue;

    if Assignable(method.GetParameters, arguments) then
    begin
      if Length(arguments) = 0 then
        ConstructorCache.AddOrSetValue(classType.Handle, method.CodeAddress);
      Exit(method);
    end;
  end;
  Result := nil;
end;

class procedure TActivator.RaiseNoConstructorFound(classType: TClass);
begin
  raise Exception.Create('No constructor with matching signature found for type: ' + classType.ClassName);
end;

function GetTypeSize(typeInfo: PTypeInfo): Integer;
const
  COrdinalSizes: array[TOrdType] of Integer = (
    SizeOf(ShortInt){1},
    SizeOf(Byte){1},
    SizeOf(SmallInt){2},
    SizeOf(Word){2},
    SizeOf(Integer){4},
    SizeOf(Cardinal){4});
  CFloatSizes: array[TFloatType] of Integer = (
    SizeOf(Single){4},
    SizeOf(Double){8},
{$IFDEF ALIGN_STACK}
    16,
{$ELSE}
    SizeOf(Extended){10},
{$ENDIF}
    SizeOf(Comp){8},
    SizeOf(Currency){8});
begin
  case typeInfo.Kind of
{$IFNDEF NEXTGEN}
    tkChar:
      Result := SizeOf(AnsiChar){1};
{$ENDIF}
    tkWChar:
      Result := SizeOf(WideChar){2};
    tkInteger, tkEnumeration:
      Result := COrdinalSizes[typeInfo.TypeData.OrdType];
    tkFloat:
      Result := CFloatSizes[typeInfo.TypeData.FloatType];
    tkString, tkLString, tkUString, tkWString, tkInterface, tkClass, tkClassRef, tkDynArray, tkPointer, tkProcedure:
      Result := SizeOf(Pointer);
    tkMethod:
      Result := SizeOf(TMethod);
    tkInt64:
      Result := SizeOf(Int64){8};
    tkVariant:
      Result := SizeOf(Variant);
    tkSet:
      Result := GetSetSize(typeInfo);
    tkRecord{$IF Declared(tkMRecord)}, tkMRecord{$IFEND}:
      Result := typeInfo.TypeData.RecSize;
    tkArray:
      Result := typeInfo.TypeData.ArrayData.Size;
  else
    Assert(False, 'Unsupported type'); { TODO -o##jwp -cEnhance : add more context to the assert }
    Result := -1;
  end;
end;

function GetSetSize(typeInfo: PTypeInfo): Integer;
var
  typeData: PTypeData;
  count: Integer;
begin
  typeData := GetTypeData(typeInfo);
  typeData := GetTypeData(typeData.CompType^);
  if typeData.MinValue = 0 then
    case typeData.MaxValue of
      0..7: Exit(1);
      8..15: Exit(2);
      16..31: Exit(4);
    end;
  count := typeData.MaxValue - typeData.MinValue + 1;
  Result := count div 8;
  if count mod 8 <> 0 then
    Inc(Result);
end;

end.
