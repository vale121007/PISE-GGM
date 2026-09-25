/* ============================================================
   COLEGIO GABRIEL GARCÍA MÁRQUEZ — interacciones
============================================================ */

const prefersReducedMotion = window.matchMedia(
  "(prefers-reduced-motion: reduce)"
).matches;

/* ============================================================
   MENÚ MÓVIL
============================================================ */
const navHamburguesa = document.getElementById("navHamburguesa");
const navLinks = document.getElementById("navLinks");

if (navHamburguesa && navLinks) {
  navHamburguesa.addEventListener("click", () => {
    const abierto = navLinks.classList.toggle("abierto");
    navHamburguesa.setAttribute("aria-expanded", abierto ? "true" : "false");
  });
  navLinks.querySelectorAll("a").forEach((enlace) => {
    enlace.addEventListener("click", () => {
      // Los enlaces del menú desplegable manejan su propio cierre abajo
      if (enlace.closest(".nav-desplegable-menu")) return;
      navLinks.classList.remove("abierto");
      navHamburguesa.setAttribute("aria-expanded", "false");
    });
  });
}

/* ============================================================
   MENÚ DESPLEGABLE — "Oferta académica"
============================================================ */
const navDesplegable = document.getElementById("navDesplegable");
const navDesplegableBtn = document.getElementById("navDesplegableBtn");
const navDesplegableMenu = document.getElementById("navDesplegableMenu");

if (navDesplegable && navDesplegableBtn && navDesplegableMenu) {
  const cerrarDesplegable = () => {
    navDesplegable.classList.remove("abierto");
    navDesplegableBtn.setAttribute("aria-expanded", "false");
  };

  navDesplegableBtn.addEventListener("click", (e) => {
    e.stopPropagation();
    const abierto = navDesplegable.classList.toggle("abierto");
    navDesplegableBtn.setAttribute("aria-expanded", abierto ? "true" : "false");
  });

  document.addEventListener("click", (e) => {
    if (!navDesplegable.contains(e.target)) cerrarDesplegable();
  });

  document.addEventListener("keydown", (e) => {
    if (e.key === "Escape") cerrarDesplegable();
  });

  // Enlaces que apuntan directamente a una etapa del sendero
  navDesplegableMenu.querySelectorAll("[data-etapa-link]").forEach((enlace) => {
    enlace.addEventListener("click", (e) => {
      const etapa = enlace.dataset.etapaLink;
      const paso = document.querySelector(`.sendero-paso[data-etapa="${etapa}"]`);
      if (paso) {
        e.preventDefault();
        paso.click();
        cerrarDesplegable();
        if (navLinks) navLinks.classList.remove("abierto");
        if (navHamburguesa) navHamburguesa.setAttribute("aria-expanded", "false");
        document.getElementById("sendero")?.scrollIntoView({
          behavior: prefersReducedMotion ? "auto" : "smooth",
          block: "start",
        });
      }
    });
  });
}

/* ============================================================
   BOTÓN SUBIR
============================================================ */
const topBtn = document.getElementById("topBtn");

window.addEventListener("scroll", () => {
  topBtn.style.display =
    document.documentElement.scrollTop > 300 ? "flex" : "none";
});

topBtn.addEventListener("click", () => {
  window.scrollTo({ top: 0, behavior: "smooth" });
});

/* ============================================================
   BARRA DE PROGRESO DE LECTURA
============================================================ */
const barraRelleno = document.getElementById("barraProgresoRelleno");

function actualizarBarraProgreso() {
  const alto = document.documentElement.scrollHeight - window.innerHeight;
  const progreso = alto > 0 ? (window.scrollY / alto) * 100 : 0;
  if (barraRelleno) barraRelleno.style.width = progreso + "%";
}

window.addEventListener("scroll", actualizarBarraProgreso);
actualizarBarraProgreso();

/* ============================================================
   MODO NOCHE (persistente)
============================================================ */
const btnModoNoche = document.getElementById("btnModoNoche");
const raizHtml = document.documentElement;

function aplicarTemaGuardado() {
  const guardado = localStorage.getItem("ggm-tema");
  if (guardado === "noche") {
    raizHtml.setAttribute("data-tema", "noche");
    actualizarIconoModoNoche(true);
  }
}

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
      raizHtml.removeAttribute("data-tema");
      localStorage.setItem("ggm-tema", "dia");
      actualizarIconoModoNoche(false);
    } else {
      raizHtml.setAttribute("data-tema", "noche");
      localStorage.setItem("ggm-tema", "noche");
      actualizarIconoModoNoche(true);
    }
  });
}

/* ============================================================
   CONTADORES ANIMADOS + ANILLO (estadísticas)
============================================================ */
function animateCounter(el, target, anilloEl) {
  const CIRCUNFERENCIA = 327;

  if (prefersReducedMotion) {
    el.textContent = target + "+";
    if (anilloEl) anilloEl.style.strokeDashoffset = "10";
    return;
  }

  let count = 0;
  const increment = target / 80;

  const interval = setInterval(() => {
    count += increment;
    if (count >= target) {
      count = target;
      clearInterval(interval);
    }
    el.textContent = Math.floor(count) + "+";
    if (anilloEl) {
      const avance = Math.min(count / target, 1);
      anilloEl.style.strokeDashoffset = CIRCUNFERENCIA - avance * (CIRCUNFERENCIA - 10);
    }
  }, 20);
}

const statsTargets = { students: 300, teachers: 20, years: 26 };
const statsSection = document.querySelector(".numeros");
let statsAnimated = false;

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
  { threshold: 0.4 }
);

if (statsSection) statsObserver.observe(statsSection);

/* ============================================================
   SENDERO — etapas
============================================================ */
const senderoPasos = document.querySelectorAll(".sendero-paso");
const senderoPaneles = document.querySelectorAll(".sendero-panel");

senderoPasos.forEach((paso) => {
  paso.addEventListener("click", () => {
    senderoPasos.forEach((p) => { p.classList.remove("activo"); p.setAttribute("aria-selected", "false"); });
    paso.classList.add("activo");
    paso.setAttribute("aria-selected", "true");
    const destino = paso.dataset.etapa;
    senderoPaneles.forEach((panel) => panel.classList.toggle("activo", panel.dataset.panel === destino));
  });
});

/* ============================================================
   GALERÍA — lightbox
============================================================ */
const figurasGaleria = Array.from(document.querySelectorAll(".galeria-mosaico figure"));
const lightbox = document.getElementById("lightbox");
const lightboxImg = document.getElementById("lightboxImg");
const lightboxCaption = document.getElementById("lightboxCaption");
let indiceLightbox = 0;

function abrirLightbox(indice) {
  if (!lightbox || figurasGaleria.length === 0) return;
  indiceLightbox = indice;
  actualizarLightbox();
  lightbox.hidden = false;
  document.body.style.overflow = "hidden";
}

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
  document.body.style.overflow = "";
}

function lightboxSiguiente() {
  indiceLightbox = (indiceLightbox + 1) % figurasGaleria.length;
  actualizarLightbox();
}

function lightboxAnterior() {
  indiceLightbox = (indiceLightbox - 1 + figurasGaleria.length) % figurasGaleria.length;
  actualizarLightbox();
}

figurasGaleria.forEach((figura, indice) => {
  figura.setAttribute("tabindex", "0");
  figura.setAttribute("role", "button");
  figura.setAttribute("aria-label", "Ver foto en grande");
  figura.addEventListener("click", () => abrirLightbox(indice));
  figura.addEventListener("keydown", (e) => {
    if (e.key === "Enter" || e.key === " ") { e.preventDefault(); abrirLightbox(indice); }
  });
});

document.getElementById("lightboxCerrar")?.addEventListener("click", cerrarLightbox);
document.getElementById("lightboxNext")?.addEventListener("click", lightboxSiguiente);
document.getElementById("lightboxPrev")?.addEventListener("click", lightboxAnterior);
lightbox?.addEventListener("click", (e) => { if (e.target === lightbox) cerrarLightbox(); });

document.addEventListener("keydown", (e) => {
  if (!lightbox || lightbox.hidden) return;
  if (e.key === "Escape") cerrarLightbox();
  if (e.key === "ArrowRight") lightboxSiguiente();
  if (e.key === "ArrowLeft") lightboxAnterior();
});

/* ============================================================
   TESTIMONIOS — carrusel arrastrable
============================================================ */
const envolturaPostales = document.getElementById("testimoniosEnvoltura");
const pistaPostales = document.getElementById("testimoniosPista");

if (envolturaPostales && pistaPostales) {
  let arrastrando = false;
  let inicioX = 0;
  let scrollInicial = 0;

  const empezarArrastre = (x) => {
    arrastrando = true;
    inicioX = x;
    scrollInicial = envolturaPostales.scrollLeft;
    envolturaPostales.classList.add("arrastrando");
  };
  const moverArrastre = (x) => {
    if (!arrastrando) return;
    envolturaPostales.scrollLeft = scrollInicial - (x - inicioX);
  };
  const terminarArrastre = () => {
    arrastrando = false;
    envolturaPostales.classList.remove("arrastrando");
  };

  envolturaPostales.addEventListener("mousedown", (e) => empezarArrastre(e.clientX));
  window.addEventListener("mousemove", (e) => moverArrastre(e.clientX));
  window.addEventListener("mouseup", terminarArrastre);
  envolturaPostales.addEventListener("touchstart", (e) => empezarArrastre(e.touches[0].clientX), { passive: true });
  envolturaPostales.addEventListener("touchmove", (e) => moverArrastre(e.touches[0].clientX), { passive: true });
  envolturaPostales.addEventListener("touchend", terminarArrastre);
  pistaPostales.addEventListener("dragstart", (e) => e.preventDefault());
}

/* ============================================================
   PREGUNTAS FRECUENTES — acordeón
============================================================ */
document.querySelectorAll(".faq-item").forEach((item) => {
  const pregunta = item.querySelector(".faq-pregunta");
  const respuesta = item.querySelector(".faq-respuesta");

  pregunta.addEventListener("click", () => {
    const abierto = item.classList.contains("abierto");

    document.querySelectorAll(".faq-item.abierto").forEach((otro) => {
      if (otro !== item) {
        otro.classList.remove("abierto");
        otro.querySelector(".faq-pregunta").setAttribute("aria-expanded", "false");
        otro.querySelector(".faq-respuesta").style.maxHeight = null;
      }
    });

    if (abierto) {
      item.classList.remove("abierto");
      pregunta.setAttribute("aria-expanded", "false");
      respuesta.style.maxHeight = null;
    } else {
      item.classList.add("abierto");
      pregunta.setAttribute("aria-expanded", "true");
      respuesta.style.maxHeight = respuesta.scrollHeight + "px";
    }
  });
});

/* ============================================================
   VIDEO INSTITUCIONAL — controles reales
============================================================ */
const videoInstitucion = document.getElementById("institucionVideo");
const btnPlayPausa = document.getElementById("btnPlayPausaVideo");
const btnSilenciar = document.getElementById("btnSilenciarVideo");

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

if (videoInstitucion && btnSilenciar) {
  btnSilenciar.addEventListener("click", () => {
    videoInstitucion.muted = !videoInstitucion.muted;
    btnSilenciar.innerHTML = videoInstitucion.muted
      ? '<i class="bi bi-volume-mute-fill"></i>'
      : '<i class="bi bi-volume-up-fill"></i>';
    btnSilenciar.setAttribute("aria-label", videoInstitucion.muted ? "Activar sonido" : "Silenciar");
  });
}