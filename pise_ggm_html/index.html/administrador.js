const usuario = JSON.parse(
    localStorage.getItem("usuario")
);


// Si no existe sesión
if (!usuario) {

    window.location.href = "login.html";

}


// Si existe pero no es administrador
if (usuario.rol.toUpperCase() !== "ADMINISTRADOR") {

    alert("No tienes permisos para acceder a este módulo.");

    window.location.href = "login.html";

}


// Mostrar nombre
document.getElementById("nombreUsuario").textContent =
    usuario.nombre + " " + usuario.apellido;


// Cerrar sesión
function cerrarSesion() {

    localStorage.removeItem("usuario");

    window.location.href = "login.html";
}