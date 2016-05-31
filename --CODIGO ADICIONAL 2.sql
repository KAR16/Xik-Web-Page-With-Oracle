--CODIGO ADICIONAL 2

Declare
   vNombre empleado.nombre%type;
Begin
 
   begin
 
      Select nombre
      into vNombre
     from empleado
      where codemp = '1256';
 
   exception
      when others then
         vNombre:=null;
   end;
 
   --Luego puedes usar el nombre consultado