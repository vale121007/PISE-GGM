// ==== Configuración ====
// Spring Boot corre en el puerto 8081
const API = "http://localhost:8081/api/reportes";

// ==== Guardia de sesión ====
const token = localStorage.getItem("token");
const usuarioRaw = localStorage.getItem("usuario");
if (!token || !usuarioRaw) {
  window.location.href = "login.html";
}
const usuario = JSON.parse(usuarioRaw);
const rol = (usuario.rol && usuario.rol.nombreRol) || "";
if (rol.toUpperCase() !== "ESTUDIANTE") {
  window.location.href = "login.html";
}

document.getElementById("nombreUsuario").textContent = usuario.nombre + " " + usuario.apellido;
document.getElementById("btnCerrarSesion").addEventListener("click", function () {
  localStorage.removeItem("token");
  localStorage.removeItem("usuario");
  localStorage.removeItem("idPerfil");
  window.location.href = "login.html";
});

// ==== Ayudantes ====
function esc(v) {
  const d = document.createElement("div");
  d.textContent = v == null ? "" : String(v);
  return d.innerHTML;
}

// Devuelve el primer campo existente (por si el DTO usa otro nombre)
function pick(o, ...campos) {
  for (const c of campos) {
    if (o[c] !== undefined && o[c] !== null) return o[c];
  }
  return "";
}

async function apiGet(ruta) {
  const resp = await fetch(API + ruta, {
    headers: { "Authorization": "Bearer " + token }
  });
  if (!resp.ok) throw new Error("Error " + resp.status + " al consultar " + ruta);
  return resp.json();
}

// Busca al estudiante logueado dentro del reporte de estudiantes
async function obtenerMiEstudiante() {
  const lista = await apiGet("/estudiantes");
  const idPerfil = localStorage.getItem("idPerfil");

  let yo = lista.find(e => idPerfil && String(e.idEstudiante) === String(idPerfil));
  if (!yo && usuario.email) {
    yo = lista.find(e => e.email && e.email.toLowerCase() === usuario.email.toLowerCase());
  }
  if (!yo) throw new Error("No se encontró tu registro de estudiante.");
  return yo;
}

function mostrarError(idContenedor, e) {
  document.getElementById(idContenedor).innerHTML =
    '<div class="alert alert-danger">' + esc(e.message) + "</div>";
}