const filters = document.querySelectorAll(".filter");
const cards = document.querySelectorAll(".skill-card");

for (const filter of filters) {
  filter.addEventListener("click", () => {
    const group = filter.dataset.filter;

    for (const button of filters) {
      button.classList.toggle("is-active", button === filter);
    }

    for (const card of cards) {
      const matches = group === "all" || card.dataset.group === group;
      card.classList.toggle("is-hidden", !matches);
    }
  });
}
