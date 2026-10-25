document.addEventListener('DOMContentLoaded', () => {

  /* ===================== NAVBAR: SOMBRA AL HACER SCROLL ===================== */
  const navbar = document.getElementById('navbar');

  const handleScroll = () => {
    if (window.scrollY > 20) {
      navbar.classList.add('scrolled');
    } else {
      navbar.classList.remove('scrolled');
    }
  };

  window.addEventListener('scroll', handleScroll);
  handleScroll();

  /* ===================== MENÚ HAMBURGUESA ===================== */
  const navToggle = document.getElementById('navbarToggle');
  const navMenu = document.getElementById('navbarMenu');

  navToggle.addEventListener('click', () => {
    navToggle.classList.toggle('active');
    navMenu.classList.toggle('active');
  });

  // Cierra el menú al hacer clic en un enlace (solo en móvil)
  document.querySelectorAll('.navbar__link').forEach(link => {
    link.addEventListener('click', () => {
      navToggle.classList.remove('active');
      navMenu.classList.remove('active');
    });
  });

  /* ===================== ANIMACIONES AL APARECER (SCROLL) ===================== */
  const animatedElements = document.querySelectorAll('[data-animate]');

  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        const delay = entry.target.dataset.delay || 0;
        setTimeout(() => {
          entry.target.classList.add('in-view');
        }, delay);
        observer.unobserve(entry.target);
      }
    });
  }, {
    threshold: 0.15
  });

  animatedElements.forEach(el => observer.observe(el));

  /* ===================== SCROLL SUAVE PARA ANCLAS INTERNAS ===================== */
  document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
      e.preventDefault();
      const target = document.querySelector(this.getAttribute('href'));
      if (target) {
        target.scrollIntoView({ behavior: 'smooth' });
      }
    });
  });

});