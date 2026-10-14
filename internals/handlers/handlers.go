package handlers

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"

	"github.com/go-chi/chi/v5"
	"nhooyr.io/websocket"

	"aayampokharel2.com/internals/service"
)

type Handler struct {
	svc *service.GameService
}

func NewHandler(svc *service.GameService) *Handler {
	return &Handler{svc: svc}
}

// ServeChat is for sending message with name like aayam:hello and broadcasting
// to all.
func (h *Handler) ServeChat(w http.ResponseWriter, r *http.Request) {
	c, err := websocket.Accept(w, r, &websocket.AcceptOptions{
		OriginPatterns: []string{"*"},
	})
	if err != nil {
		if c != nil {
			fmt.Print("from error 1")
			c.Close(websocket.StatusNormalClosure, "cross origin WebSocket accepted")
		}
		return

	}

	h.svc.HandleChat(r.Context(), c)
}

func (h *Handler) ServePaint(w http.ResponseWriter, r *http.Request) {
	c, err := websocket.Accept(w, r, &websocket.AcceptOptions{
		OriginPatterns: []string{"*"},
	})
	if err != nil {
		if c != nil {
			fmt.Print("from error 3")
			c.Close(websocket.StatusNormalClosure, "cross origin WebSocket accepted")
		}
		return

	}

	h.svc.HandlePaint(r.Context(), c)
}

func (h *Handler) ServeCheck(w http.ResponseWriter, r *http.Request) {
	ca, err := websocket.Accept(w, r, &websocket.AcceptOptions{
		OriginPatterns: []string{"*"},
	})
	if err != nil { //
		if ca != nil {
			fmt.Print("from error check")

			if h.svc.IsStreamLocked() {

				defer h.svc.UnlockStream()
			}
			ca.Close(websocket.StatusNormalClosure, "cross origin WebSocket accepted")
		}
		return

	}

	h.svc.HandleStream(r.Context(), ca)
}

// ServeCurrentCheck takes the current player name and adds it in the list of
// players, then returns the first player's name.
func (h *Handler) ServeCurrentCheck(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
	w.Header().Set("Access-Control-Allow-Headers", "Accept, Authorization, Content-Type, X-CSRF-Token")

	var nameOfCurrentPlayer string
	byteName, _ := io.ReadAll(r.Body)
	json.Unmarshal(byteName, &nameOfCurrentPlayer)

	firstPlayerName := h.svc.AddPlayer(nameOfCurrentPlayer)

	w.Write([]byte(firstPlayerName))

}

// ServeListOfNames returns the list of players to the drawing drawer.
func (h *Handler) ServeListOfNames(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
	w.Header().Set("Access-Control-Allow-Headers", "Accept, Authorization, Content-Type, X-CSRF-Token")

	listOfAllNames := h.svc.GetPlayers()
	if len(listOfAllNames) == 0 {
		//! use THE SAME  lock or somethng as concurrent countFor timER IS CRITICAL . ===============================
		return
	}
	listAsJson, _ := json.Marshal(listOfAllNames)

	w.Write([]byte(listAsJson))

}

func (h *Handler) ServeListOfWords(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
	w.Header().Set("Access-Control-Allow-Headers", "Accept, Authorization, Content-Type, X-CSRF-Token")

	sliceJson, _ := json.Marshal(h.svc.GetCurrentWord())
	//returning just a single value from slice

	w.Write((sliceJson))

}

func (h *Handler) ServeProgressBar(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
	w.Header().Set("Access-Control-Allow-Headers", "Accept, Authorization, Content-Type, X-CSRF-Token")

	w.Write([]byte(fmt.Sprintf("%f", h.svc.GetProgress())))

} //@ <<=========HERE IS AN ERROR PANIC TO SOLVE LATER. ===>>>>>>

func (h *Handler) RegisterRoutes(r chi.Router) {
	r.Get("/", h.ServeChat)
	r.Get("/listofnames", h.ServeListOfNames)
	r.Post("/currentcheck", h.ServeCurrentCheck)
	r.Get("/paint", h.ServePaint)
	r.Get("/check", h.ServeCheck)
	r.Get("/listofwords", h.ServeListOfWords)
	r.Get("/progressbar", h.ServeProgressBar)
}
