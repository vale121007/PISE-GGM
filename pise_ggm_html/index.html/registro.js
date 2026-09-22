// ==========================================
// CONFIGURACIÓN
// ==========================================
const API_URL = "http://localhost:8082/api/auth/registro";

const registroForm = document.getElementById("registroForm");
const mensajeDiv = document.getElementById("mensaje");

registroForm.addEventListener("submit", async (event) => {
    event.preventDefault(); // evita que la página se recargue

    // Recolectamos los datos del formulario
    const datos = {
        tipoDocumento: document.getElementById("tipoDocumento").value,
        documento: document.getElementById("documento").value,
        nombre: document.getElementById("nombre").value,
        apellido: document.getElementById("apellido").value,
        telefono: document.getElementById("telefono").value,
        email: document.getElementById("email").value,
        password: document.getElementById("password").value,
        // El DTO espera un número (Integer), el <select> nos da texto
        idRol: parseInt(document.getElementById("rol").value, 10)
    };

    // Validación básica antes de enviar
    if (!datos.tipoDocumento || !datos.idRol) {
        mostrarMensaje("Por favor selecciona tipo de documento y rol.", "error");
        return;
    }

    // Validación de la contraseña: mínimo 6 caracteres, una mayúscula,
    // un número y un carácter especial
    const errorPassword = validarPassword(datos.password);
    if (errorPassword) {
        mostrarMensaje(errorPassword, "error");
        return;
    }

    try {
        const respuesta = await fetch(API_URL, {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify(datos)
        });

        const resultado = await respuesta.json();

        if (respuesta.ok) {
            mostrarMensaje(resultado.mensaje || "Registro exitoso", "exito");
            registroForm.reset();

            // Redirige al login después de un momento
            setTimeout(() => {
                window.location.href = "login.html";
            }, 1500);
        } else {
            // El backend respondió con error (400, etc.)
            mostrarMensaje(resultado.error || "No se pudo completar el registro.", "error");
        }

    } catch (error) {
        // Error de red: el backend no está corriendo, CORS, url mal escrita, etc.
        console.error("Error al registrar:", error);
        mostrarMensaje("No se pudo conectar con el servidor. Verifica que el backend esté encendido.", "error");
    }
});

function mostrarMensaje(texto, tipo) {
    mensajeDiv.textContent = texto;
    mensajeDiv.className = tipo === "exito" ? "mensaje-exito" : "mensaje-error";
}

// ==========================================
// VALIDACIÓN DE CONTRASEÑA
// ==========================================
// Reglas: mínimo 6 caracteres, al menos una mayúscula,
// al menos un número y al menos un carácter especial.
// Devuelve un mensaje de error (string) si algo falla,
// o null si la contraseña cumple todo.
function validarPassword(password) {
    if (!password) {
        return "La contraseña es obligatoria.";
    }

    const faltantes = [];

    if (password.length < 6) {
        faltantes.push("al menos 6 caracteres");
    }

    if (!/[A-Z]/.test(password)) {
        faltantes.push("una letra mayúscula");
    }

    if (!/[0-9]/.test(password)) {
        faltantes.push("un número");
    }

    if (!/[!@#$%^&*(),.?":{}|<>_\-+=/\\[\];'`~]/.test(password)) {
        faltantes.push("un carácter especial (ej: !@#$%)");
    }

    if (faltantes.length === 0) {
        return null; // la contraseña cumple con todo
    }

    return "La contraseña debe tener: " + faltantes.join(", ") + ".";
}