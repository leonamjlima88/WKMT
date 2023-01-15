unit uPessoa.Show.DTO;

interface

uses
  uPessoa.Store.DTO,
  uPessoa.FlNatureza.Types;

type
  TPessoaShowDTO = class(TPessoaStoreDTO)
  private
    Fdtregistro: TDateTime;
    Fidpessoa: Int64;
    Fflnatureza: TPessoaFlNaturezaType;
    Fendereco_idendereco: Int64;
  public
    property idpessoa: Int64 read Fidpessoa write Fidpessoa;
    property flnatureza: TPessoaFlNaturezaType read Fflnatureza write Fflnatureza;
    property dtregistro: TDateTime read Fdtregistro write Fdtregistro;
    property endereco_idendereco: Int64 read Fendereco_idendereco write Fendereco_idendereco;
  end;

implementation

end.
