async function login() {

    const documento = document.getElementById("user").value;
    const password = document.getElementById("pass").value;
    const rol = document.getElementById("rol").value;

    if (rol === "") {
        alert("Selecciona un rol");
        return;
    }

    const datos = {
        documento: documento,
        password: password,
        rol: rol
    };

    try {

        const respuesta = await fetch("http://localhost:8082/api/auth/login", {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify(datos)
        });

        const resultado = await respuesta.json();

        if (respuesta.ok) {

            const usuario = resultado.usuario;

            // El rol real viene del backend, no del desplegable — así evitamos que
            // alguien seleccione un rol distinto al que realmente tiene su usuario.
            const nombreRol =
                ((usuario.rol && usuario.rol.nombreRol) || "").trim().toUpperCase();

            alert("¡Bienvenido " + usuario.nombre + "!");

            switch (nombreRol) {

                case "ADMINISTRADOR":
                    window.location.href = "administrador.html";
                    break;

                case "DOCENTE":
                    window.location.href = "docente.html";
                    break;

                case "ESTUDIANTE":
                    window.location.href = "estudiante.html";
                    break;

                case "ACUDIENTE":
                    window.location.href = "acudiente.html";
                    break;

                default:
                    alert("Rol no reconocido: [" + nombreRol + "]");
            }

        } else {
            alert(resultado.error || resultado.mensaje || "Usuario o contraseña incorrectos");
        }

    } catch (error) {

        console.error(error);

        alert("No fue posible conectar con el servidor.");
    }
}