/* ============================================================
   COLEGIO GABRIEL GARCÍA MÁRQUEZ — PISE-GGM
   SCRIPT GENERAL DEL SITIO (script.js)
============================================================

   ¿PARA QUÉ SIRVE ESTE ARCHIVO?
   Contiene las interacciones COMPARTIDAS por casi todas las
   páginas: menú de celular, botón "subir", barra de progreso,
   modo noche, contadores animados, galería de fotos, carrusel,
   preguntas frecuentes y controles del video.

   ¿CÓMO FUNCIONA?
   Cada bloque busca sus elementos en la página por su "id" o
   "class" (ej. "navHamburguesa", ".faq-item"). Si la página no
   tiene esos elementos, ese bloque simplemente no hace nada.
   Por eso un mismo script sirve para todas las páginas.

   ÍNDICE DE BLOQUES (búscalos con Ctrl+F)
     1. MENÚ MÓVIL              6. GALERÍA — lightbox
     2. BOTÓN SUBIR             7. TESTIMONIOS — carrusel
     3. BARRA DE PROGRESO       8. PREGUNTAS FRECUENTES
     4. MODO NOCHE              9. VIDEO INSTITUCIONAL
     5. CONTADORES + SENDERO

   ¿QUÉ SE EDITA CON MÁS FRECUENCIA?
   - Las cifras del inicio (estudiantes, docentes, años):
     busca "statsTargets" en el bloque 5.
   - Cuántos píxeles hay que bajar para ver el botón "subir":
     busca "> 300" en el bloque 2.

   OJO: si cambias el "id" de un elemento en el HTML, también
   debes cambiarlo aquí, o esa función dejará de funcionar.
============================================================ */

/* ¿El usuario pidió "reducir movimiento" en su dispositivo?
   Si es así, se omiten las animaciones (accesibilidad). */
const prefersReducedMotion = window.matchMedia(
  "(prefers-reduced-motion: reduce)"
).matches;

/* ============================================================
   1. MENÚ MÓVIL
   En celular, el botón de 3 rayitas (#navHamburguesa) abre y
   cierra la lista de enlaces (#navLinks). La clase "abierto" es
   la que hace que el menú baje (ver style.css, sección NAV).
============================================================ */
const navHamburguesa = document.getElementById("navHamburguesa");
const navLinks = document.getElementById("navLinks");

if (navHamburguesa && navLinks) {
  // Al pulsar la hamburguesa: abre o cierra el menú
  navHamburguesa.addEventListener("click", () => {
    const abierto = navLinks.classList.toggle("abierto");
    // aria-expanded avisa a lectores de pantalla si está abierto
    navHamburguesa.setAttribute("aria-expanded", abierto ? "true" : "false");
  });
  // Al pulsar cualquier enlace del menú: se cierra solo
  navLinks.querySelectorAll("a").forEach((enlace) => {
    enlace.addEventListener("click", () => {
      navLinks.classList.remove("abierto");
      navHamburguesa.setAttribute("aria-expanded", "false");
    });
  });
}

/* ============================================================
   2. BOTÓN SUBIR
   La flecha flotante (#topBtn) aparece cuando se baja más de
   300 píxeles y, al pulsarla, sube suavemente al inicio.

   NOTA: login.html no tiene este botón. Antes, el script se
   detenía con error en esa página (y el modo noche no
   funcionaba). Ahora solo se activa si el botón existe.
============================================================ */
const topBtn = document.getElementById("topBtn");

if (topBtn) {
  window.addEventListener("scroll", () => {
    // > 300 = píxeles que hay que bajar para que aparezca (editable)
    topBtn.style.display =
      document.documentElement.scrollTop > 300 ? "flex" : "none";
  });

  topBtn.addEventListener("click", () => {
    window.scrollTo({ top: 0, behavior: "smooth" });
  });
}

/* ============================================================
   3. BARRA DE PROGRESO DE LECTURA
   La línea amarilla de arriba (#barraProgresoRelleno) se llena
   de 0% a 100% según cuánto se haya bajado en la página.
============================================================ */
const barraRelleno = document.getElementById("barraProgresoRelleno");

function actualizarBarraProgreso() {
  // alto = cuánto se puede desplazar la página en total
  const alto = document.documentElement.scrollHeight - window.innerHeight;
  // progreso = porcentaje ya recorrido (si no hay scroll, 0%)
  const progreso = alto > 0 ? (window.scrollY / alto) * 100 : 0;
  if (barraRelleno) barraRelleno.style.width = progreso + "%";
}

window.addEventListener("scroll", actualizarBarraProgreso);
actualizarBarraProgreso(); // se ejecuta una vez al cargar

/* ============================================================
   4. MODO NOCHE (persistente)
   El botón de la luna (#btnModoNoche) alterna entre día y noche.
   Funciona poniendo o quitando data-tema="noche" en <html>;
   los colores de noche están en style.css (sección MODO NOCHE).
   La elección se guarda en el navegador (clave "ggm-tema") para
   que se recuerde en todas las páginas y en la próxima visita.
============================================================ */
const btnModoNoche = document.getElementById("btnModoNoche");
const raizHtml = document.documentElement; // la etiqueta <html>

// Al cargar: si el usuario ya había elegido "noche", se aplica
function aplicarTemaGuardado() {
  const guardado = localStorage.getItem("ggm-tema");
  if (guardado === "noche") {
    raizHtml.setAttribute("data-tema", "noche");
    actualizarIconoModoNoche(true);
  }
}

// Cambia el icono del botón: sol en modo noche, luna en modo día
function actualizarIconoModoNoche(esNoche) {
  if (!btnModoNoche) return;
  btnModoNoche.innerHTML = esNoche
    ? '<i class="bi bi-sun-fill"></i>'
    : '<i class="bi bi-moon-stars-fill"></i>';
}

if (btnModoNoche) {
  aplicarTemaGuardado();
  btnModoNoche.addEventListener("click", () => {
    const esNocheAhora = raizHtml.getAttribute("data-tema") === "noche";
    if (esNocheAhora) {
      // Pasar a DÍA
      raizHtml.removeAttribute("data-tema");
      localStorage.setItem("ggm-tema", "dia");
      actualizarIconoModoNoche(false);
    } else {
      // Pasar a NOCHE
      raizHtml.setAttribute("data-tema", "noche");
      localStorage.setItem("ggm-tema", "noche");
      actualizarIconoModoNoche(true);
    }
  });
}

/* ============================================================
   5a. CONTADORES ANIMADOS + ANILLO (estadísticas del inicio)
   Cuando la sección ".numeros" aparece en pantalla, los números
   suben desde 0 hasta su cifra final y el anillo se va llenando.
============================================================ */
function animateCounter(el, target, anilloEl) {
  // Largo total del anillo SVG (debe coincidir con el dibujo en el HTML)
  const CIRCUNFERENCIA = 327;

  // Si el usuario pidió menos movimiento: muestra la cifra final directo
  if (prefersReducedMotion) {
    el.textContent = target + "+";
    if (anilloEl) anilloEl.style.strokeDashoffset = "10";
    return;
  }

  let count = 0;
  const increment = target / 80; // el conteo se hace en 80 pasos

  // Cada 20 milisegundos suma un paso (en total ~1,6 segundos)
  const interval = setInterval(() => {
    count += increment;
    if (count >= target) {
      count = target;
      clearInterval(interval); // llegó a la meta: detiene el conteo
    }
    el.textContent = Math.floor(count) + "+";
    if (anilloEl) {
      const avance = Math.min(count / target, 1);
      anilloEl.style.strokeDashoffset = CIRCUNFERENCIA - avance * (CIRCUNFERENCIA - 10);
    }
  }, 20);
}

/* ► AQUÍ SE CAMBIAN LAS CIFRAS DEL INICIO
   La clave (students, teachers, years) es el "id" del número en
   el HTML; el valor es la cifra final que se mostrará.      */
const statsTargets = { students: 300, teachers: 20, years: 26 };
const statsSection = document.querySelector(".numeros");
let statsAnimated = false; // para que la animación ocurra una sola vez

// El "observador" avisa cuando la sección entra a la pantalla
const statsObserver = new IntersectionObserver(
  (entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting && !statsAnimated) {
        statsAnimated = true;
        Object.entries(statsTargets).forEach(([id, target]) => {
          const el = document.getElementById(id);
          const anillo = el ? el.parentElement.querySelector("[data-anillo]") : null;
          if (el) animateCounter(el, target, anillo);
        });
      }
    });
  },
  { threshold: 0.4 } // se activa cuando se ve el 40% de la sección
);

if (statsSection) statsObserver.observe(statsSection);

/* ============================================================
   5b. SENDERO — etapas
   Pestañas: al pulsar un ".sendero-paso" se resalta y se
   muestra el ".sendero-panel" que tenga el mismo nombre
   (data-etapa del paso = data-panel del panel).
============================================================ */
const senderoPasos = document.querySelectorAll(".sendero-paso");
const senderoPaneles = document.querySelectorAll(".sendero-panel");

senderoPasos.forEach((paso) => {
  paso.addEventListener("click", () => {
    // Desmarca todos los pasos...
    senderoPasos.forEach((p) => { p.classList.remove("activo"); p.setAttribute("aria-selected", "false"); });
    // ...y marca solo el pulsado
    paso.classList.add("activo");
    paso.setAttribute("aria-selected", "true");
    // Muestra el panel que corresponde y oculta los demás
    const destino = paso.dataset.etapa;
    senderoPaneles.forEach((panel) => panel.classList.toggle("activo", panel.dataset.panel === destino));
  });
});

/* ============================================================
   6. GALERÍA — lightbox (visor de fotos a pantalla completa)
   Al pulsar una foto de ".galeria-mosaico" se abre en grande.
   Se puede navegar con las flechas de pantalla o del teclado y
   cerrar con la X, con Escape o pulsando fuera de la foto.
============================================================ */
const figurasGaleria = Array.from(document.querySelectorAll(".galeria-mosaico figure"));
const lightbox = document.getElementById("lightbox");
const lightboxImg = document.getElementById("lightboxImg");
const lightboxCaption = document.getElementById("lightboxCaption");
let indiceLightbox = 0; // posición de la foto que se está viendo

// Abre el visor en la foto número "indice"
function abrirLightbox(indice) {
  if (!lightbox || figurasGaleria.length === 0) return;
  indiceLightbox = indice;
  actualizarLightbox();
  lightbox.hidden = false;
  document.body.style.overflow = "hidden"; // evita que la página de atrás se mueva
}

// Pone la foto y el texto (figcaption) de la posición actual
function actualizarLightbox() {
  const figura = figurasGaleria[indiceLightbox];
  const img = figura.querySelector("img");
  const caption = figura.querySelector("figcaption");
  lightboxImg.src = img.src;
  lightboxImg.alt = img.alt || "";
  lightboxCaption.textContent = caption ? caption.textContent : "";
}

function cerrarLightbox() {
  lightbox.hidden = true;
  document.body.style.overflow = ""; // devuelve el scroll de la página
}

// "% longitud" hace que al llegar a la última foto vuelva a la primera
function lightboxSiguiente() {
  indiceLightbox = (indiceLightbox + 1) % figurasGaleria.length;
  actualizarLightbox();
}

function lightboxAnterior() {
  indiceLightbox = (indiceLightbox - 1 + figurasGaleria.length) % figurasGaleria.length;
  actualizarLightbox();
}

// Cada foto de la galería se vuelve "clicable" y accesible con teclado
figurasGaleria.forEach((figura, indice) => {
  figura.setAttribute("tabindex", "0");
  figura.setAttribute("role", "button");
  figura.setAttribute("aria-label", "Ver foto en grande");
  figura.addEventListener("click", () => abrirLightbox(indice));
  figura.addEventListener("keydown", (e) => {
    if (e.key === "Enter" || e.key === " ") { e.preventDefault(); abrirLightbox(indice); }
  });
});

// Botones del visor (el "?." evita errores si la página no los tiene)
document.getElementById("lightboxCerrar")?.addEventListener("click", cerrarLightbox);
document.getElementById("lightboxNext")?.addEventListener("click", lightboxSiguiente);
document.getElementById("lightboxPrev")?.addEventListener("click", lightboxAnterior);
// Pulsar el fondo oscuro (fuera de la foto) también cierra
lightbox?.addEventListener("click", (e) => { if (e.target === lightbox) cerrarLightbox(); });

// Atajos de teclado (solo cuando el visor está abierto)
document.addEventListener("keydown", (e) => {
  if (!lightbox || lightbox.hidden) return;
  if (e.key === "Escape") cerrarLightbox();
  if (e.key === "ArrowRight") lightboxSiguiente();
  if (e.key === "ArrowLeft") lightboxAnterior();
});

/* ============================================================
   7. TESTIMONIOS — carrusel arrastrable
   Permite deslizar las tarjetas de testimonios con el mouse
   (mantener pulsado y arrastrar) o con el dedo en celular.
============================================================ */
const envolturaPostales = document.getElementById("testimoniosEnvoltura");
const pistaPostales = document.getElementById("testimoniosPista");

if (envolturaPostales && pistaPostales) {
  let arrastrando = false; // ¿se está arrastrando ahora?
  let inicioX = 0;         // posición horizontal donde empezó el arrastre
  let scrollInicial = 0;   // desplazamiento que tenía el carrusel al empezar

  const empezarArrastre = (x) => {
    arrastrando = true;
    inicioX = x;
    scrollInicial = envolturaPostales.scrollLeft;
    envolturaPostales.classList.add("arrastrando"); // cambia el cursor (CSS)
  };
  const moverArrastre = (x) => {
    if (!arrastrando) return;
    // Mueve el carrusel lo mismo que se movió el puntero
    envolturaPostales.scrollLeft = scrollInicial - (x - inicioX);
  };
  const terminarArrastre = () => {
    arrastrando = false;
    envolturaPostales.classList.remove("arrastrando");
  };

  // Mouse
  envolturaPostales.addEventListener("mousedown", (e) => empezarArrastre(e.clientX));
  window.addEventListener("mousemove", (e) => moverArrastre(e.clientX));
  window.addEventListener("mouseup", terminarArrastre);
  // Pantalla táctil
  envolturaPostales.addEventListener("touchstart", (e) => empezarArrastre(e.touches[0].clientX), { passive: true });
  envolturaPostales.addEventListener("touchmove", (e) => moverArrastre(e.touches[0].clientX), { passive: true });
  envolturaPostales.addEventListener("touchend", terminarArrastre);
  // Evita que el navegador "arrastre" las imágenes como archivos
  pistaPostales.addEventListener("dragstart", (e) => e.preventDefault());
}

/* ============================================================
   8. PREGUNTAS FRECUENTES — acordeón
   Cada ".faq-item" tiene una ".faq-pregunta" (el título) y una
   ".faq-respuesta". Al pulsar la pregunta se despliega su
   respuesta y se cierran las demás (solo una abierta a la vez).
   Para agregar una pregunta nueva basta copiar un ".faq-item"
   en el HTML; no hay que tocar este código.
============================================================ */
document.querySelectorAll(".faq-item").forEach((item) => {
  const pregunta = item.querySelector(".faq-pregunta");
  const respuesta = item.querySelector(".faq-respuesta");

  pregunta.addEventListener("click", () => {
    const abierto = item.classList.contains("abierto");

    // Cierra cualquier otra pregunta que esté abierta
    document.querySelectorAll(".faq-item.abierto").forEach((otro) => {
      if (otro !== item) {
        otro.classList.remove("abierto");
        otro.querySelector(".faq-pregunta").setAttribute("aria-expanded", "false");
        otro.querySelector(".faq-respuesta").style.maxHeight = null;
      }
    });

    if (abierto) {
      // Estaba abierta: se cierra
      item.classList.remove("abierto");
      pregunta.setAttribute("aria-expanded", "false");
      respuesta.style.maxHeight = null;
    } else {
      // Estaba cerrada: se abre con la altura exacta de su texto
      item.classList.add("abierto");
      pregunta.setAttribute("aria-expanded", "true");
      respuesta.style.maxHeight = respuesta.scrollHeight + "px";
    }
  });
});

/* ============================================================
   9. VIDEO INSTITUCIONAL — controles reales
   Botón de reproducir/pausar (#btnPlayPausaVideo) y de
   silenciar (#btnSilenciarVideo) para el video #institucionVideo.
   Cada botón cambia su icono y su texto accesible según el estado.
============================================================ */
const videoInstitucion = document.getElementById("institucionVideo");
const btnPlayPausa = document.getElementById("btnPlayPausaVideo");
const btnSilenciar = document.getElementById("btnSilenciarVideo");

// Reproducir / Pausar
if (videoInstitucion && btnPlayPausa) {
  btnPlayPausa.addEventListener("click", () => {
    if (videoInstitucion.paused) {
      videoInstitucion.play();
      btnPlayPausa.innerHTML = '<i class="bi bi-pause-fill"></i>';
      btnPlayPausa.setAttribute("aria-label", "Pausar video");
    } else {
      videoInstitucion.pause();
      btnPlayPausa.innerHTML = '<i class="bi bi-play-fill"></i>';
      btnPlayPausa.setAttribute("aria-label", "Reproducir video");
    }
  });
}

// Silenciar / Activar sonido
if (videoInstitucion && btnSilenciar) {
  btnSilenciar.addEventListener("click", () => {
    videoInstitucion.muted = !videoInstitucion.muted;
    btnSilenciar.innerHTML = videoInstitucion.muted
      ? '<i class="bi bi-volume-mute-fill"></i>'
      : '<i class="bi bi-volume-up-fill"></i>';
    btnSilenciar.setAttribute("aria-label", videoInstitucion.muted ? "Activar sonido" : "Silenciar");
  });
}