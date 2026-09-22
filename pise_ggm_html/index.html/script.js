AOS.init({ once: true });

const topBtn = document.getElementById("topBtn");

/* Botón subir */
window.addEventListener("scroll", () => {
  topBtn.style.display =
    document.documentElement.scrollTop > 300 ? "block" : "none";
});

topBtn.addEventListener("click", () => {
  window.scrollTo({ top: 0, behavior: "smooth" });
});

/* Contadores animados */
function animateCounter(id, target) {
  let count = 0;
  const increment = target / 100;

  const interval = setInterval(() => {
    count += increment;
    if (count >= target) {
      count = target;
      clearInterval(interval);
    }
    document.getElementById(id).textContent = Math.floor(count) + "+";
  }, 30);
}

animateCounter("students", 300);
animateCounter("teachers", 20);
animateCounter("years", 26);