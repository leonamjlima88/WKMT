-- public.pessoa definition

-- Drop table

-- DROP TABLE public.pessoa;

CREATE TABLE public.pessoa (
	idpessoa bigserial NOT NULL,
	flnatureza int2 NOT NULL,
	dsdocumento varchar(20) NOT NULL,
	nmprimeiro varchar(100) NOT NULL,
	nmsegundo varchar(100) NOT NULL,
	dtregistro date NULL,
	CONSTRAINT pessoa_pk PRIMARY KEY (idpessoa)
);

-- public.endereco definition

-- Drop table

-- DROP TABLE public.endereco;

CREATE TABLE public.endereco (
	idendereco bigserial NOT NULL,
	idpessoa int8 NOT NULL,
	dscep varchar(15) NULL,
	CONSTRAINT endereco_pk PRIMARY KEY (idendereco)
);
CREATE INDEX endereco_idpessoa ON public.endereco USING btree (idpessoa);


-- public.endereco foreign keys

ALTER TABLE public.endereco ADD CONSTRAINT endereco_fk_pessoa FOREIGN KEY (idpessoa) REFERENCES public.pessoa(idpessoa) ON DELETE CASCADE;


-- public.endereco_integracao definition

-- Drop table

-- DROP TABLE public.endereco_integracao;

CREATE TABLE public.endereco_integracao (
	idendereco int8 NOT NULL,
	dsuf varchar(50) NULL,
	nmcidade varchar(100) NULL,
	nmbairro varchar(50) NULL,
	nmlogradouro varchar(100) NULL,
	dscomplemento varchar(100) NULL,
	CONSTRAINT enderecointegracao_pk PRIMARY KEY (idendereco)
);


-- public.endereco_integracao foreign keys

ALTER TABLE public.endereco_integracao ADD CONSTRAINT enderecointegracao_fk_endereco FOREIGN KEY (idendereco) REFERENCES public.endereco(idendereco) ON DELETE CASCADE;


-- public.tarefa definition

-- Drop table

-- DROP TABLE public.tarefa;

CREATE TABLE public.tarefa (
	idtarefa bigserial NOT NULL,
	identificacao varchar(36) NOT NULL,
	status int2 NOT NULL,
	mensagem varchar(255) NULL,
	dtinicio date NULL,
	dtfim date NULL,
	CONSTRAINT tarefa_pk PRIMARY KEY (idtarefa)
);