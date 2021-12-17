begin;

drop table if exists Cittadino;
drop table if exists Vaccino;
drop table if exists centro;
drop table if exists Medico;
drop table if exists Lotto;
drop table if exists Prenotazione;
drop table if exists Vaccinazione;

create table Cittadino(
	CF char(16) primary key,
	Nome varchar not null,
	Cognome varchar not null,
	Ddn date not null,
	citta varchar not null,
	indirizzo varchar not null,
	categoria varchar not null
);

create table Vaccino(
	Nome varchar primary key,
	etaMin integer not null,
	etaMax integer not null,
	numeroDosi integer,
	intervallo interval day
);

create table centro(
	indirizzo varchar not null,
	citta varchar not null,
	primary key(indirizzo, citta)
);

create table Medico(
	CF char(16) references Cittadino(CF) primary key,
	tipo varchar not null,
	Sede varchar not null,
	CittaS varchar not null,
	foreign key (Sede,CittaS) references Centro(indirizzo, citta)
);

create table Lotto(
	CL char(20) primary key,
	Nome varchar references Vaccino(Nome) not null,
	ddp date not null,
	dds date not null,
	qty integer not null,
	indirizzo varchar not null,
	città varchar not null,
	foreign key (indirizzo, città) references Centro(indirizzo, città)
);

create table Prenotazione(
	CFptr varchar unique not null,
	Recapito varchar not null,
	Allergie boolean not null,
	Covid boolean not null,
	primary key (Recapito)
);

create table Vaccinazione(
	CFvnd char(16) references Prenotazione(CF) not null, 
	CFmed char(16) references Medico(CF) not null,
	indirizzo varchar not null,
	citta varchar not null,
	lotto1 char(20) references Lotto(CL) not null,
	lotto2 char(20) references Lotto(CL),
	vaccino varchar references Vaccino(nome) not null,
	dv1 date not null,
	dv2 date,
	esito boolean not null,
	primary key (CFvnd),
	foreign key(indirizzo, citta) references Centro(indirizzo, citta),
	--checks if CFmed's reference to medico.CF Sede, CittaS is the same reference lotto1 to Lotto.CL indirizzo, citta
	check((select Sede, CittaS from Medico where CFmed=Medico.CF) = (select indirizzo, citta from Lotto where lotto1=Lotto.CL)),
	--checks if Vaccino's reference to Vaccino nome is the same reference lotto1 to Lotto.nome
	check((select Nome from Lotto where lotto1=Locco.CL)= vaccino)
	--checks if lotto1 and lotto2 refer to the same indirizzo, citta
	check((lotto2 is not null) and ((select indirizzo, citta from Lotto where lotto1=Lotto.CL) = (select indirizzo, citta from Lotto where lotto2=Lotto.CL))),
	--checks if when lotto2 is null also dv2 is null
	check((lotto2 is null and dv2 is null) or (lotto2 is not null and dv2 is not null)),
	--checks if Vaccino's reference to Vaccino nome is the same reference lotto1 to Lotto.nome
	check((select Nome from Lotto where lotto2=Lotto.CL) = vaccino),
	--checks if CFvnd reference to Cittadino citta is the same reference to citta
	check((select città from Cittadino where Cfvnd=Cittadino.CF) = citta),
	--checks if when vaccino reference to Vaccino.nome is FLUSTOP dv2 must be null  
	check((vaccino like 'FLUSTOP') and (dv2 is null)),
	--checks if when vaccino reference to Vaccino.nome is CORONAX or COVIDIN dv2 can be either null or not null, based on CFvnd reference on Prenotaione.CFptr Codiv value or esito
	check(((vaccino like 'CORONAX' or vaccino like 'COVIDIN') and (dv2 is not null)) or ((select Covid from Prenotazione where Prenotazione.CFptr=CFvnd) and (dv2 is null)) or esito),
	--check if when vaccino reference to Vaccino.nome is FLUSTOP CFmed refers to Medico.CF of tipo = 'altro'
	check((vaccino like 'FLUSTOP') and (select tipo from Medico where Medico.CF = CFmed) like 'altro'),
	--
	check((vaccino like 'FLUSTOP') and (""select from where Cittadino.CF=CFvnd))
	--
	check((vaccino like 'CORONAX') and (" not in select from where Cittadino.CF=CFvnd))
	--
	check((vaccino like 'COVIDIN') and (select from where Cittadino.CF=CFvnd))
);

commit;