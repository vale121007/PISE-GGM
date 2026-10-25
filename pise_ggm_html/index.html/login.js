async function login() {

    const email = document.getElementById("user").value;
    const password = document.getElementById("pass").value;
    const rol = document.getElementById("rol").value;

    if (rol === "") {
        alert("Selecciona un rol");
        return;
    }

    const datos = {
        email: email,
        password: password,
        rol: rol
    };

    try {

        const respuesta = await fetch("http://localhost:8081/api/login", {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify(datos)
        });

        const resultado = await respuesta.json();

        if (respuesta.ok) {

            alert("¡Bienvenido a PISE-GGM!");

            if (rol === "maestro") {
                window.location.href = "docente.html";

            } else if (rol === "estudiante") {
                window.location.href = "estudiante.html";

            } else if (rol === "acudiente") {
                window.location.href = "acudiente.html";
            }

        } else {
            alert(resultado.mensaje || "Usuario o contraseña incorrectos");
        }

    } catch (error) {

        console.error(error);

        alert("No fue posible conectar con el servidor.");
    }
}