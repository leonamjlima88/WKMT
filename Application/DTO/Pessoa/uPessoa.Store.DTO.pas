unit uPessoa.Store.DTO;

interface

uses
  uBase.DTO;

type
  TPessoaStoreDTO = class(TBaseDTO)
  private
    Fnmprimeiro: String;
    Fnmsegundo: String;
    Fdsdocumento_value: String;
    Fendereco_dscep: String;
  public
    property dsdocumento_value: String read Fdsdocumento_value write Fdsdocumento_value;
    property nmprimeiro: String read Fnmprimeiro write Fnmprimeiro;
    property nmsegundo: String read Fnmsegundo write Fnmsegundo;
    property endereco_dscep: String read Fendereco_dscep write Fendereco_dscep;
  end;

implementation


end.
