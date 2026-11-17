describe('Sitio PISE-GGM', () => {
  it('CP-01: carga la página de inicio', () => {
    cy.visit('/pise_ggm_html/index.html/index.html')
    cy.get('body').should('be.visible')
  })

  it('CP-02: carga la página de login', () => {
    cy.visit('/pise_ggm_html/index.html/login.html')
    cy.get('input').should('exist')
  })
})

describe('Login PISE-GGM', () => {
  beforeEach(() => {
    cy.visit('/pise_ggm_html/index.html/login.html')
  })

  it('CP-03: muestra los campos del formulario', () => {
    cy.contains('¡Hola de nuevo!').should('be.visible')
    cy.get('input[placeholder="Ej. 1234567890"]').should('be.visible')
    cy.get('input[placeholder="Tu contraseña"]').should('be.visible')
    cy.contains('Rol').should('be.visible')
  })

  it('CP-04: permite escribir en los campos', () => {
    cy.get('input[placeholder="Ej. 1234567890"]')
      .type('1234567890')
      .should('have.value', '1234567890')
    cy.get('input[placeholder="Tu contraseña"]')
      .type('clave123')
      .should('have.value', 'clave123')
  })

  it('CP-05: con el formulario vacío no sale del login', () => {
    cy.get('form button').last().click()
    cy.url().should('include', 'login.html')
  })
})