INSERT INTO public.provincial_server(
	id, version, port, code, username, url_path, password, destination)
	VALUES ('59BA4DAD-A32F-4B60-84D9-4A7F7E8C84GC', 0, 3113, 'MIGRATION', 'postgres', 'http://172.0.0.1:', 'postgres', 'IDART');
	--onde
	--id -UUID do registo
	--port - porta do postgrest do IDART
	--code - código
	--username -username do postgrest
	--passwdord -password do postgrest
	--url_path - Host onde está a correr o postgrest do IDART,
	--destination -A Fonte de dados que irá alimentar o IDMED
