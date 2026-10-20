package repository

import (
	"sync"

	"nhooyr.io/websocket"

	"aayampokharel2.com/internals/models"
)

type GameRepository struct {
	Slices               []string
	MapOfConnection      map[*websocket.Conn]string
	MapOfConnections     map[*websocket.Conn]bool
	MapForStream         map[*websocket.Conn]bool
	Mutex                *sync.Mutex
	Mutex1               *sync.Mutex
	Mutex2               *sync.Mutex
	Mutex3               *sync.Mutex
	Mutex4               *sync.Mutex
	FromReturn           *sync.Mutex //! error in length panic error
	GlobalCurrentName    string
	Index                int
	Ind                  int
	CountForTimer        float64
	ToogleForTimer       bool
	Mutex4LockCheck      bool //@initially set to false and true when mutex4 acquired./.
	ListOfAllNames       []models.PlayerPoints
	NameForMap           chan string
	ToogleForProgressBar bool
}

func NewGameRepository() *GameRepository {
	return &GameRepository{
		Slices:           []string{"ball", "brother", "cricket", "football", "hello", "pencil", "red", "yellow", "blue", "baseball", "ant", "elephant", "orange"},
		MapOfConnection:  make(map[*websocket.Conn]string),
		MapOfConnections: make(map[*websocket.Conn]bool),
		MapForStream:     make(map[*websocket.Conn]bool),
		Mutex:            &sync.Mutex{},
		Mutex1:           &sync.Mutex{},
		Mutex2:           &sync.Mutex{},
		Mutex3:           &sync.Mutex{},
		Mutex4:           &sync.Mutex{},
		FromReturn:       &sync.Mutex{},
		ToogleForTimer:   true,
		Mutex4LockCheck:  false,
		ListOfAllNames:   []models.PlayerPoints{},
		NameForMap:       make(chan string, 100),
	}
}

func deleteFromSlice(slice []models.PlayerPoints, name string) []models.PlayerPoints {

	for i := range slice {
		if slice[i].Name == name {

			return append(slice[:i], slice[i+1:]...)
		}
	}

	return slice
}

func (r *GameRepository) DeleteFromSlice(name string) {
	r.ListOfAllNames = deleteFromSlice(r.ListOfAllNames, name)
}
