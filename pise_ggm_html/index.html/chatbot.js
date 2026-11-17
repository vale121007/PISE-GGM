/* ============================================================
   Asistente virtual — Colegio Gabriel García Márquez (PISE-GGM)
   Sin servidor, sin API de pago: responde con la información del sitio.
   Para actualizar datos, edita SOLO la sección "DATOS" y "RESPUESTAS".
============================================================ */
(function () {
  'use strict';

  /* ---------- DATOS (edítalos aquí) ---------- */
  var D = {
    nombre: 'Colegio Gabriel García Márquez',
    tel: '87472004',
    cel: '3143316222',
    correo: 'colggm@gmail.com',
    dir: 'Tv. 3 #67-14, Tunja, Boyacá',
    instagram: 'https://www.instagram.com/colggmtunja/',
    pdfAdmision: 'PROCESO DE ADMISIÓN Y REQUISITOS 2026.pdf',
    horario: 'Lunes a viernes de 7:00 a.m. a 5:00 p.m.'
  };

  var a = function (href, txt) { return '<a href="' + encodeURI(href) + '">' + txt + '</a>'; };
  var ext = function (href, txt) { return '<a href="' + href + '" target="_blank" rel="noopener">' + txt + '</a>'; };
  var tel = '<a href="tel:' + D.tel + '">' + D.tel + '</a>';
  var cel = '<a href="tel:+57' + D.cel + '">' + D.cel + '</a>';
  var wa = ext('https://wa.me/57' + D.cel, 'WhatsApp');

  /* ---------- RESPUESTAS ----------
     k = palabras clave (sin tildes, en minúscula) | r = respuesta (HTML) | c = botones sugeridos */
  var R = [
    { id: 'saludo', k: ['hola', 'buenas', 'buenos dias', 'buenas tardes', 'buenas noches', 'buen dia', 'hey'],
      r: '¡Hola! 👋 Soy el asistente del ' + D.nombre + '. Puedo ayudarte con admisiones, contacto, calendario, el campus virtual y a moverte por el sitio. ¿Qué necesitas?',
      c: ['Admisiones', 'Cómo llamar', 'Campus virtual', 'No entiendo el sitio'] },

    { id: 'contacto', k: ['llamar', 'telefono', 'numero', 'contacto', 'contactar', 'correo', 'email', 'direccion', 'ubicacion', 'donde queda', 'donde estan', 'como llegar', 'celular', 'whatsapp', 'comunicar', 'escribir'],
      r: '📞 <b>Cómo contactarnos</b><br>• Teléfono: ' + tel + '<br>• Celular: ' + cel + ' (' + wa + ')<br>• Correo: <a href="mailto:' + D.correo + '">' + D.correo + '</a><br>• Dirección: ' + D.dir + '<br>• Instagram: ' + ext(D.instagram, '@colggmtunja') + '<br>También puedes usar el ' + a('contacto.html', 'formulario de contacto') + '.',
      c: ['Admisiones', 'Horario de atención'] },

    { id: 'horario', k: ['horario', 'hora de atencion', 'atienden', 'abren', 'cierran', 'visita', 'agendar'],
      r: '🕒 <b>Horario de atención</b><br>' + D.horario + '<br><br>Para agendar una visita llámanos al ' + tel + ' o al ' + cel + ', o escribe a ' + D.correo + '.',
      c: ['Cómo llamar', 'Admisiones'] },

    { id: 'admision', k: ['admision', 'admisiones', 'inscrib', 'inscripcion', 'matricula', 'matricular', 'cupo', 'aspirante', 'requisito', 'ingresar al colegio', 'entrar al colegio', 'estudiante nuevo', 'como entro', 'proceso'],
      r: '🎓 <b>Proceso de admisión</b><br>1. Consigna el valor de la inscripción y envía el comprobante al correo indicado en el documento oficial.<br>2. Acércate con una copia del recibo a la sede principal para programar la entrevista familiar con psicología y la prueba de conocimientos (de 1.° a 11.°).<br>3. Lleva: registro civil o tarjeta de identidad, informes académicos del colegio anterior y copia del observador.<br>4. El colegio te comunica los resultados y, si todo está en orden, asigna el cupo y empieza la matrícula.<br><br>📄 ' + a(D.pdfAdmision, 'Descargar el documento oficial (PDF)') + '<br>Más detalles en ' + a('matriculas.html', 'Admisiones') + '. Dudas: ' + cel + '.',
      c: ['Costos', 'Cómo llamar', 'Oferta académica'] },

    { id: 'costos', k: ['costo', 'cuesta', 'pension', 'precio', 'valor', 'mensualidad', 'tarifa', 'cuanto', 'pagar', 'pago', 'banco'],
      r: '💳 El documento de admisión indica un valor de inscripción de <b>$110.000</b> (incluye entrevista con psicología y prueba de conocimientos). Revisa el ' + a(D.pdfAdmision, 'PDF oficial') + ' para los datos de pago y confirma que el valor siga vigente.<br>Sobre pensión y matrícula no tengo información publicada: consúltalo al ' + tel + ' o ' + cel + '.',
      c: ['Admisiones', 'Cómo llamar'] },

    { id: 'oferta', k: ['oferta', 'nivel', 'preescolar', 'primaria', 'bachillerato', 'grado', 'transicion', 'que ofrecen', 'que ensenan', 'jornada', 'academico'],
      r: '📚 <b>Oferta académica</b><br>• <b>Preescolar:</b> aprendizaje a través del juego, grupos pequeños e inglés desde transición.<br>• <b>Primaria:</b> lectura crítica, pensamiento lógico-matemático y proyectos de ciencia y tecnología.<br>• <b>Bachillerato:</b> preparación para Pruebas Saber 11° y articulación con universidades aliadas, con énfasis técnico.<br>Mira todo en ' + a('oferta.html', 'Oferta académica') + '.',
      c: ['Técnico en sistemas', 'Bilingüismo', 'Admisiones'] },

    { id: 'tecnico', k: ['tecnico', 'sistemas', 'programacion', 'programador', 'robotica', 'titulo', 'doble titulacion', 'certificacion', 'modulos', 'tecnologia'],
      r: '💻 Somos un <b>colegio técnico en sistemas y programación</b>, en articulación con el SENA. Desde 2025 los estudiantes se forman como programadores desde preescolar hasta bachillerato y se certifican según los módulos cursados. También hay proyectos de robótica. Más en ' + a('matriculas.html', 'Admisiones') + ' y ' + a('oferta.html', 'Oferta académica') + '.',
      c: ['Convenios', 'Admisiones'] },

    { id: 'ingles', k: ['ingles', 'bilingue', 'bilinguismo', 'idioma'],
      r: '🌎 El inglés se integra en varias asignaturas desde preescolar (transición) hasta bachillerato: es un bilingüismo real, no solo una clase aparte. Detalles en ' + a('oferta.html', 'Oferta académica') + '.',
      c: ['Oferta académica'] },

    { id: 'convenios', k: ['convenio', 'uptc', 'sena', 'universidad', 'santo tomas', 'uniboyaca', 'aliados', 'alianza'],
      r: '🤝 <b>Convenios institucionales</b><br>• UPTC: articulación con programas técnicos y acceso a educación superior.<br>• SENA Boyacá: formación técnica complementaria.<br>• Universidad de Boyacá: orientación vocacional y emprendimiento escolar.<br>• Universidad Santo Tomás: certificación y acompañamiento a la calidad educativa.<br>Los verás en el ' + a('index.html#inicio', 'inicio') + ' del sitio.',
      c: ['Técnico en sistemas', 'Admisiones'] },

    { id: 'calendario', k: ['calendario', 'periodo', 'vacaciones', 'receso', 'semana santa', 'fechas', 'cuando empiezan', 'cuando inicia', 'cuando terminan', 'ano lectivo', 'cronograma'],
      r: '📅 <b>Calendario académico 2026</b><br>• 1.er periodo: 2 feb – 10 abr<br>• Receso Semana Santa: 30 mar – 3 abr<br>• 2.º periodo: 13 abr – 12 jun<br>• Receso mitad de año: 22 jun – 6 jul<br>• 3.er periodo: 6 jul – 11 sep<br>• 4.º periodo: 14 sep – 27 nov<br>• Receso estudiantil: 5 – 11 oct<br>Verlo completo en ' + a('calendario.html', 'Calendario') + '.',
      c: ['Noticias', 'Cómo llamar'] },

    { id: 'campus', k: ['campus', 'plataforma', 'login', 'iniciar sesion', 'ingresar', 'entrar', 'notas', 'boletin', 'calificaciones', 'mi curso', 'perfil', 'acudiente', 'docente', 'profesor', 'estudiante'],
      r: '🖥️ <b>Campus virtual (PISE-GGM)</b><br>1. Ve a ' + a('login.html', 'Ingresar') + '.<br>2. Escribe tu <b>número de documento</b> y tu contraseña.<br>3. Elige tu <b>rol</b> (Administrador, Docente, Estudiante o Acudiente) y pulsa INGRESAR.<br>Ahí consultas notas, curso y perfil según tu rol.<br>¿No tienes cuenta? ' + a('registro.html', 'Regístrate') + '. ¿Olvidaste la clave? ' + a('recuperarContraseña.html', 'Recupérala aquí') + '.',
      c: ['Olvidé mi contraseña', 'Registrarme'] },

    { id: 'clave', k: ['contrasena', 'clave', 'olvide', 'recuperar', 'codigo', 'restablecer', 'no puedo entrar'],
      r: '🔑 <b>Recuperar contraseña</b> en 3 pasos desde ' + a('recuperarContraseña.html', 'esta página') + ':<br>1. Escribe tu documento y el correo con el que te registraste.<br>2. Ingresa el código de 6 dígitos que te llega al correo (vence en 10 minutos).<br>3. Crea tu nueva contraseña (mínimo 6 caracteres, con mayúscula, minúscula, número y carácter especial).<br>Si no llega el código, revisa spam o llama al ' + tel + '.',
      c: ['Campus virtual', 'Cómo llamar'] },

    { id: 'registro', k: ['registr', 'crear cuenta', 'cuenta nueva', 'no tengo cuenta', 'darme de alta', 'inscribirme en la plataforma'],
      r: '📝 <b>Crear tu cuenta</b>: entra a ' + a('registro.html', 'Registro') + ', completa tus datos (paso 1), elige correo, contraseña y tu rol (Docente, Estudiante o Acudiente) (paso 2). Un administrador del colegio revisa la solicitud y, cuando te apruebe, ya puedes ingresar con tu documento y contraseña.',
      c: ['Campus virtual', 'Olvidé mi contraseña'] },

    { id: 'manual', k: ['manual', 'convivencia', 'normas', 'reglas', 'deberes', 'derechos', 'disciplina', 'comportamiento'],
      r: '📘 El Manual de Convivencia reúne principios, derechos, deberes y normas de la comunidad. Léelo en ' + a('manual-convivencia.html', 'Manual de Convivencia') + '.',
      c: ['Quiénes somos'] },

    { id: 'nosotros', k: ['quienes somos', 'historia', 'mision', 'vision', 'fundadora', 'fundacion', 'fundaron', ' anos ', 'identidad', 'valores', 'sobre el colegio', 'colegio'],
      r: '🏫 Somos una institución privada y mixta en Tunja, con más de 26 años formando niños y jóvenes en valores, conocimiento y sentido humano. Nació en 1999 como Sala Maternal Pilatunas, fundada por la Esp. María Estella Buitrago Muñoz. Lee la misión, visión e historia en ' + a('quienessomos.html', '¿Quiénes somos?') + '.',
      c: ['Oferta académica', 'Admisiones'] },

    { id: 'noticias', k: ['noticia', 'banda', 'marcial', 'microfutbol', 'futbol', 'voleibol', 'voley', 'deporte', 'actividad', 'evento', 'musica', 'cultural'],
      r: '📰 Ahora hay inscripciones abiertas para <b>banda marcial</b>, <b>microfútbol</b> y <b>voleibol</b>: acércate a ' + D.dir + ' o llama al ' + tel + '. Más novedades en ' + a('noticias.html', 'Noticias') + '.',
      c: ['Cómo llamar', 'Calendario'] },

    { id: 'redes', k: ['instagram', 'facebook', 'youtube', 'redes', 'tiktok', 'siguenos'],
      r: '📱 Síguenos en Instagram: ' + ext(D.instagram, '@colggmtunja') + '. En ' + a('matriculas.html', 'Admisiones') + ' también encuentras nuestro canal de YouTube y testimonios de familias.' },

    { id: 'icfes', k: ['icfes', 'saber 11', 'categoria', 'clasificacion', 'a+', 'ranking', 'resultados'],
      r: '🏅 El colegio tiene clasificación <b>A+</b> (máxima categoría ICFES) y está entre los mejores de Tunja. Más en el ' + a('index.html', 'inicio') + '.' },

    { id: 'persona', k: ['asesor', 'persona', 'humano', 'hablar con alguien', 'secretaria', 'recepcion'],
      r: '👩‍💼 Con gusto te atiende una persona: llama al ' + tel + ' o al ' + cel + ' (' + wa + '), o escribe a <a href="mailto:' + D.correo + '">' + D.correo + '</a>.' },

    { id: 'gracias', k: ['gracias', 'chao', 'adios', 'hasta luego', 'listo', 'perfecto'],
      r: '¡Con mucho gusto! 😊 Si necesitas algo más, aquí estoy.', c: ['Admisiones', 'Cómo llamar'] }
  ];

  /* ---------- AYUDA POR PÁGINA ("no entiendo el sitio") ---------- */
  var MAPA = '<br><br><b>Mapa del sitio</b><br>' +
    a('index.html', 'Inicio') + ' · ' + a('quienessomos.html', '¿Quiénes somos?') + ' · ' + a('oferta.html', 'Oferta académica') + ' · ' +
    a('noticias.html', 'Noticias') + ' · ' + a('calendario.html', 'Calendario') + ' · ' + a('matriculas.html', 'Admisiones') + ' · ' +
    a('manual-convivencia.html', 'Manual') + ' · ' + a('login.html', 'Ingresar') + ' · ' + a('contacto.html', 'Contacto');

  var PAGINA = {
    'index': 'Estás en el <b>inicio</b>. Arriba tienes el menú; el botón verde <b>Ingresar</b> lleva al campus virtual y <b>Solicitar información</b> a admisiones. Baja para ver bienvenida, niveles, galería y convenios.',
    'oferta': 'Estás en <b>Oferta académica</b>: aquí ves los tres niveles (preescolar, primaria y bachillerato) y nuestro enfoque. Al final puedes agendar una visita.',
    'quienessomos': 'Estás en <b>¿Quiénes somos?</b>: misión, visión y la historia del colegio, que puedes recorrer como un libro.',
    'noticias': 'Estás en <b>Noticias</b>: inscripciones abiertas y actividades del colegio.',
    'calendario': 'Estás en el <b>Calendario</b>: periodos académicos y recesos del año. Usa los filtros para ver solo periodos o recesos.',
    'matriculas': 'Estás en <b>Admisiones</b>: paso 1, descarga los requisitos; paso 2, mira los videos; paso 3, contáctanos.',
    'login': 'Estás en <b>Ingresar</b>: escribe tu documento, tu contraseña y elige tu rol. Si no tienes cuenta, usa "Registrarse".',
    'registro': 'Estás en <b>Registro</b>: son 2 pasos (tus datos y tu cuenta). Después el colegio aprueba tu solicitud.',
    'recuperarContraseña': 'Estás en <b>Recuperar contraseña</b>: 3 pasos (datos, código de 6 dígitos y nueva clave).',
    'contacto': 'Estás en <b>Contacto</b>: llena el formulario con tu nombre, correo y solicitud.',
    'manual-convivencia': 'Estás en el <b>Manual de Convivencia</b>: pulsa "Ver Manual de Convivencia" para abrir el documento.'
  };

  var AYUDA_KEYS = ['no entiendo', 'ayuda', 'como uso', 'como funciona', 'perdi', 'perdido', 'donde encuentro', 'donde esta', 'mapa', 'menu', 'navegar', 'sitio', 'pagina', 'que es esto', 'que hago'];

  function paginaActual() {
    var f = decodeURIComponent(location.pathname.split('/').pop() || 'index.html').replace(/\.html?$/i, '');
    return f || 'index';
  }

  /* ---------- MOTOR DE COINCIDENCIA ---------- */
  function norm(s) {
    return ' ' + s.toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/[^a-z0-9+ ]/g, ' ').replace(/\s+/g, ' ').trim() + ' ';
  }
  function puntaje(txt, keys) {
    var p = 0;
    keys.forEach(function (k) { if (txt.indexOf(k) > -1) p += k.length; });
    return p;
  }
  function responder(texto) {
    var t = norm(texto), mejor = null, max = 0;
    if (puntaje(t, AYUDA_KEYS) > 0 && puntaje(t, ['contrasena', 'clave', 'admision', 'matricula']) === 0) {
      return { r: (PAGINA[paginaActual()] || 'Te ayudo a ubicarte en el sitio.') + MAPA, c: ['Admisiones', 'Campus virtual', 'Cómo llamar'] };
    }
    R.forEach(function (x) { var p = puntaje(t, x.k); if (p > max) { max = p; mejor = x; } });
    if (mejor) return mejor;
    return {
      r: 'No estoy seguro de haber entendido 🤔. Prueba con una de estas opciones o contacta a una persona: ' + tel + ' · ' + cel + ' · <a href="mailto:' + D.correo + '">' + D.correo + '</a>.',
      c: ['Admisiones', 'Cómo llamar', 'Campus virtual', 'No entiendo el sitio']
    };
  }

  /* ---------- ESTILOS ---------- */
  var css = '\
#ggm-bot-btn{position:fixed;right:24px;bottom:24px;width:58px;height:58px;border-radius:50%;border:none;cursor:pointer;background:var(--verde-700,#1F6B45);color:#fff;box-shadow:0 8px 22px rgba(15,61,46,.35);z-index:2500;display:flex;align-items:center;justify-content:center;transition:transform .2s,background .2s}\
#ggm-bot-btn:hover{transform:scale(1.07);background:var(--verde-900,#0F3D2E)}\
#ggm-bot-btn .pt{position:absolute;top:2px;right:2px;width:14px;height:14px;border-radius:50%;background:var(--amarillo-500,#F2C230);border:2px solid #fff}\
#topBtn{bottom:94px!important}\
#ggm-bot{position:fixed;right:24px;bottom:96px;width:370px;max-width:calc(100vw - 32px);height:540px;max-height:calc(100vh - 120px);background:var(--blanco,#FFFDF8);color:var(--tinta,#17241B);border:1px solid var(--borde,rgba(23,36,27,.12));border-radius:18px;box-shadow:0 20px 50px rgba(15,61,46,.3);display:none;flex-direction:column;overflow:hidden;z-index:2500;font-family:system-ui,-apple-system,"Segoe UI",Roboto,sans-serif;font-size:14.5px}\
#ggm-bot.abierto{display:flex;animation:ggmUp .25s ease}\
@keyframes ggmUp{from{opacity:0;transform:translateY(12px)}to{opacity:1;transform:none}}\
#ggm-bot header{background:linear-gradient(135deg,var(--verde-900,#0F3D2E),var(--verde-700,#1F6B45));color:#fff;padding:14px 16px;display:flex;align-items:center;gap:12px}\
#ggm-bot header img{width:38px;height:38px;border-radius:50%;background:#fff;object-fit:contain;padding:2px}\
#ggm-bot header b{display:block;font-size:15px}\
#ggm-bot header small{opacity:.85;font-size:12px}\
#ggm-bot header button{margin-left:auto;background:none;border:none;color:#fff;font-size:24px;cursor:pointer;line-height:1}\
#ggm-log{flex:1;overflow-y:auto;padding:14px;display:flex;flex-direction:column;gap:10px;background:var(--verde-100,#E9F3E7)}\
.ggm-m{max-width:86%;padding:10px 13px;border-radius:14px;line-height:1.45;word-wrap:break-word}\
.ggm-m a{color:var(--verde-700,#1F6B45);font-weight:600;text-decoration:underline}\
.ggm-bot{align-self:flex-start;background:var(--blanco,#fff);border:1px solid var(--borde,rgba(0,0,0,.1));border-bottom-left-radius:4px}\
.ggm-yo{align-self:flex-end;background:var(--verde-700,#1F6B45);color:#fff;border-bottom-right-radius:4px}\
.ggm-chips{display:flex;flex-wrap:wrap;gap:6px;align-self:flex-start}\
.ggm-chips button{border:1.5px solid var(--verde-700,#1F6B45);background:var(--blanco,#fff);color:var(--verde-700,#1F6B45);border-radius:999px;padding:6px 12px;font-size:13px;cursor:pointer;font-family:inherit}\
.ggm-chips button:hover{background:var(--amarillo-500,#F2C230);border-color:var(--amarillo-500,#F2C230);color:#0F3D2E}\
.ggm-esc{display:flex;gap:4px;padding:10px 14px}.ggm-esc i{width:7px;height:7px;border-radius:50%;background:#9bb;animation:ggmP 1s infinite}.ggm-esc i:nth-child(2){animation-delay:.15s}.ggm-esc i:nth-child(3){animation-delay:.3s}\
@keyframes ggmP{0%,60%,100%{opacity:.3}30%{opacity:1}}\
#ggm-bot form{display:flex;gap:8px;padding:10px;border-top:1px solid var(--borde,rgba(0,0,0,.1));background:var(--blanco,#fff)}\
#ggm-bot input{flex:1;border:1.5px solid var(--borde,rgba(0,0,0,.2));border-radius:999px;padding:10px 14px;font-size:14.5px;font-family:inherit;background:var(--blanco,#fff);color:var(--tinta,#17241B);outline:none}\
#ggm-bot input:focus{border-color:var(--verde-500,#2D8B57)}\
#ggm-bot form button{border:none;background:var(--amarillo-500,#F2C230);color:#0F3D2E;font-weight:700;border-radius:999px;padding:0 16px;cursor:pointer}\
#ggm-bot .nota{text-align:center;font-size:11px;opacity:.65;padding:0 10px 8px;background:var(--blanco,#fff)}\
@media(max-width:480px){#ggm-bot{right:8px;left:8px;bottom:88px;width:auto;max-width:none}#ggm-bot-btn{right:16px;bottom:16px}}';

  /* ---------- INTERFAZ ---------- */
  var st = document.createElement('style'); st.textContent = css; document.head.appendChild(st);

  var btn = document.createElement('button');
  btn.id = 'ggm-bot-btn'; btn.setAttribute('aria-label', 'Abrir asistente virtual');
  btn.innerHTML = '<svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 12a8 8 0 0 1-11.6 7.1L4 20l1.1-4.6A8 8 0 1 1 21 12z"/><circle cx="9" cy="12" r=".6"/><circle cx="12.5" cy="12" r=".6"/><circle cx="16" cy="12" r=".6"/></svg><span class="pt"></span>';

  var box = document.createElement('div');
  box.id = 'ggm-bot'; box.setAttribute('role', 'dialog'); box.setAttribute('aria-label', 'Asistente virtual');
  box.innerHTML = '<header><img src="ESCUDOGGMSINFONDO.png" alt="" onerror="this.style.display=\'none\'"><div><b>Asistente GGM</b><small>Te ayudo con el colegio y el sitio</small></div><button type="button" aria-label="Cerrar">×</button></header>' +
    '<div id="ggm-log" aria-live="polite"></div>' +
    '<form autocomplete="off"><input type="text" placeholder="Escribe tu pregunta…" aria-label="Tu pregunta" maxlength="200"><button type="submit">Enviar</button></form>' +
    '<div class="nota">Asistente automático · para casos especiales llama al ' + D.tel + '</div>';

  document.body.appendChild(box); document.body.appendChild(btn);
  var log = box.querySelector('#ggm-log'), input = box.querySelector('input'), saludado = false;

  function scroll() { log.scrollTop = log.scrollHeight; }
  function burbuja(html, clase, esTexto) {
    var d = document.createElement('div'); d.className = 'ggm-m ' + clase;
    if (esTexto) d.textContent = html; else d.innerHTML = html;
    log.appendChild(d); scroll(); return d;
  }
  function chips(lista) {
    if (!lista || !lista.length) return;
    var w = document.createElement('div'); w.className = 'ggm-chips';
    lista.forEach(function (t) {
      var b = document.createElement('button'); b.type = 'button'; b.textContent = t;
      b.onclick = function () { enviar(t); }; w.appendChild(b);
    });
    log.appendChild(w); scroll();
  }
  function enviar(texto) {
    texto = (texto || '').trim(); if (!texto) return;
    log.querySelectorAll('.ggm-chips').forEach(function (c) { c.remove(); });
    burbuja(texto, 'ggm-yo', true);
    var esc = document.createElement('div'); esc.className = 'ggm-m ggm-bot ggm-esc'; esc.innerHTML = '<i></i><i></i><i></i>';
    log.appendChild(esc); scroll();
    setTimeout(function () {
      esc.remove();
      var res = responder(texto);
      burbuja(res.r, 'ggm-bot'); chips(res.c);
    }, 450);
  }
  function abrir(v) {
    box.classList.toggle('abierto', v);
    btn.setAttribute('aria-label', v ? 'Cerrar asistente virtual' : 'Abrir asistente virtual');
    if (v) {
      if (!saludado) {
        saludado = true;
        burbuja('¡Hola! 👋 Soy el asistente del <b>' + D.nombre + '</b>. Pregúntame por admisiones, contacto, calendario o el campus virtual, o dime si no entiendes algo del sitio.', 'ggm-bot');
        chips(['Admisiones', 'Cómo llamar', 'Campus virtual', 'Calendario', 'No entiendo el sitio']);
      }
      setTimeout(function () { input.focus(); }, 50);
    }
  }
  btn.onclick = function () { abrir(!box.classList.contains('abierto')); };
  box.querySelector('header button').onclick = function () { abrir(false); };
  box.querySelector('form').onsubmit = function (e) { e.preventDefault(); enviar(input.value); input.value = ''; };
  document.addEventListener('keydown', function (e) { if (e.key === 'Escape') abrir(false); });
})();