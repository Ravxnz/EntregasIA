package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

// Platillo representa un plato con su nombre e ingredientes.
type Platillo struct {
	Nombre       string
	Ingredientes []string
}

// Inventario es un mapa de ingrediente -> cantidad disponible.
type Inventario map[string]int

// Menú de platillos.
var menu = []Platillo{
	{"Enchiladas", []string{"tortilla", "pollo", "salsa verde", "queso", "crema"}},
	{"Tacos al pastor", []string{"tortilla", "carne de cerdo", "piña", "cebolla", "cilantro", "salsa roja"}},
	{"Mole poblano", []string{"pollo", "mole", "arroz", "tortilla"}},
	{"Chiles rellenos", []string{"chile poblano", "queso", "huevo", "jitomate", "cebolla"}},
	{"Arroz a la mexicana", []string{"arroz", "jitomate", "cebolla", "chile serrano", "ajo"}},
}

// Inventario inicial.
var inventario = Inventario{
	"tortilla":       10,
	"pollo":          5,
	"salsa verde":    3,
	"queso":          8,
	"crema":          4,
	"carne de cerdo": 6,
	"piña":           3,
	"cebolla":        7,
	"cilantro":       2,
	"salsa roja":     5,
	"mole":           2,
	"arroz":          12,
	"chile poblano":  4,
	"huevo":          20,
	"jitomate":       9,
	"chile serrano":  3,
	"ajo":            6,
}

// obtenerIngredientes devuelve los ingredientes de un platillo por nombre.
func obtenerIngredientes(nombre string) ([]string, bool) {
	for _, p := range menu {
		if strings.EqualFold(p.Nombre, nombre) {
			return p.Ingredientes, true
		}
	}
	return nil, false
}

// estanDisponibles verifica si todos los ingredientes de un platillo están disponibles.
func estanDisponibles(ingredientes []string) bool {
	for _, ing := range ingredientes {
		if cant, ok := inventario[ing]; !ok || cant <= 0 {
			return false
		}
	}
	return true
}

// faltantes devuelve los ingredientes que faltan (cantidad <= 0 o no existen).
func faltantes(ingredientes []string) []string {
	var faltan []string
	for _, ing := range ingredientes {
		if cant, ok := inventario[ing]; !ok || cant <= 0 {
			faltan = append(faltan, ing)
		}
	}
	return faltan
}

func main() {
	scanner := bufio.NewScanner(os.Stdin)
	fmt.Println("=== Sistema Experto - Menú e Inventario ===")
	fmt.Println("Comandos:")
	fmt.Println("  ingredientes <platillo>")
	fmt.Println("  disponible <platillo>")
	fmt.Println("  faltante <platillo>")
	fmt.Println("  listar (muestra todos los platillos)")
	fmt.Println("  salir")
	fmt.Println()

	for {
		fmt.Print("> ")
		if !scanner.Scan() {
			break
		}
		entrada := strings.TrimSpace(scanner.Text())
		if entrada == "" {
			continue
		}
		if entrada == "salir" {
			break
		}
		if entrada == "listar" {
			fmt.Println("Platillos disponibles:")
			for _, p := range menu {
				fmt.Printf("- %s: %v\n", p.Nombre, p.Ingredientes)
			}
			continue
		}

		partes := strings.SplitN(entrada, " ", 2)
		if len(partes) < 2 {
			fmt.Println("Comando incompleto. Use: comando <platillo>")
			continue
		}
		comando, nombrePlatillo := partes[0], partes[1]
		ingredientes, ok := obtenerIngredientes(nombrePlatillo)
		if !ok {
			fmt.Printf("Platillo '%s' no encontrado.\n", nombrePlatillo)
			continue
		}

		switch comando {
		case "ingredientes":
			fmt.Printf("Ingredientes de %s: %v\n", nombrePlatillo, ingredientes)
		case "disponible":
			if estanDisponibles(ingredientes) {
				fmt.Printf("Todos los ingredientes para %s están disponibles.\n", nombrePlatillo)
			} else {
				fmt.Printf("Faltan ingredientes para %s.\n", nombrePlatillo)
			}
		case "faltante":
			faltan := faltantes(ingredientes)
			if len(faltan) == 0 {
				fmt.Printf("No faltan ingredientes para %s.\n", nombrePlatillo)
			} else {
				fmt.Printf("Faltan los siguientes ingredientes para %s: %v\n", nombrePlatillo, faltan)
			}
		default:
			fmt.Println("Comando no reconocido.")
		}
	}
}
