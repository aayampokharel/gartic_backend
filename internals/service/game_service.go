package service

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"nhooyr.io/websocket"

	"aayampokharel2.com/internals/models"
	"aayampokharel2.com/internals/repository"
)

type GameService struct {
	repo *repository.GameRepository
}

func NewGameService(repo *repository.GameRepository) *GameService {
	return &GameService{repo: repo}
}

// HandleChat is for sending message with name like aayam:hello and broadcasting
// to all.
func (s *GameService) HandleChat(ctx context.Context, c *websocket.Conn) {
	//as the list will be updated after the mutex2 only.
	s.repo.MapOfConnection[c] = <-s.repo.NameForMap

	for {
		_, channelJson, err := c.Read(ctx)
		if err != nil {
			if c != nil {
				fmt.Print("from error 2")
				s.repo.FromReturn.Lock()

				s.repo.Mutex2.Lock() //? whhy this extra layer of lock? ..not reqd .

				s.repo.DeleteFromSlice(s.repo.MapOfConnection[c])
				if len(s.repo.ListOfAllNames) == 0 {

					s.repo.Ind = 0

				}
				if s.repo.MapOfConnection[c] == s.repo.GlobalCurrentName {

					s.repo.ToogleForTimer = false //@ thisis if yellow exits in middle, then we can stream out break keyword.

				}

				s.repo.Mutex2.Unlock()
				delete(s.repo.MapOfConnection, c)

				s.repo.FromReturn.Unlock()

				c.Close(websocket.StatusNormalClosure, "cross origin WebSocket accepted")
			}

			return
		}

		var msgText models.MessageText
		json.Unmarshal(channelJson, &msgText)

		if msgText.Message != "" {
			s.repo.Mutex1.Lock()

			fmt.Print("✔✔", s.repo.Ind, "✔✔")

			if s.repo.Slices[s.repo.Ind] == msgText.Message {
				for val := range s.repo.ListOfAllNames {
					if s.repo.ListOfAllNames[val].Name == msgText.Name {
						s.repo.ListOfAllNames[val].Points += 10
						break
					}
				}
				msgText.Message = "Gave Correct Answer. BRAVO !!"
				response, _ := json.Marshal(msgText)
				for k := range s.repo.MapOfConnection {

					k.Write(ctx, websocket.MessageText, response)

				}

			} else {
				for k := range s.repo.MapOfConnection {

					k.Write(ctx, websocket.MessageText, channelJson)

				}
			}
			s.repo.Mutex1.Unlock()
		} else {
			s.repo.Mutex1.Lock()

			for k := range s.repo.MapOfConnection { //@ why is this requiired for " " ?
				k.Write(ctx, websocket.MessageText, []byte(" "))

			}
			s.repo.Mutex1.Unlock()

		}
	}
}

func (s *GameService) HandlePaint(ctx context.Context, c *websocket.Conn) {
	s.repo.MapOfConnections[c] = true

	for {
		_, paintJson, err := c.Read(ctx)
		if err != nil {
			delete(s.repo.MapOfConnections, c)
			// mutex.Unlock();
			if c != nil {
				fmt.Print("from error 4")
				c.Close(websocket.StatusNormalClosure, "cross origin WebSocket accepted")

			}

			return

		}
		s.repo.Mutex.Lock()
		for k := range s.repo.MapOfConnections {
			k.Write(ctx, websocket.MessageText, paintJson)
		}
		s.repo.Mutex.Unlock()
	}
}

func (s *GameService) IsStreamLocked() bool {
	return s.repo.Mutex4LockCheck
}

func (s *GameService) UnlockStream() {
	s.repo.Mutex4.Unlock()
}

func (s *GameService) HandleStream(ctx context.Context, ca *websocket.Conn) {
	s.repo.Mutex4.Lock()

	s.repo.Mutex4LockCheck = true
	s.repo.MapForStream[ca] = true //!also use lock

	// Send the current player name immediately
	if len(s.repo.ListOfAllNames) == 0 {

		s.repo.Mutex4.Unlock()
		s.repo.Ind = 0
		return
	}
	er := ca.Write(ctx, websocket.MessageText, []byte(s.repo.ListOfAllNames[0].Name))
	if s.repo.ToogleForProgressBar { //// check properly for the break function exit garera jodiepachi pani straight break  option print aako  cha
		ca.Write(ctx, websocket.MessageText, []byte("Break"))
	}

	s.repo.Mutex4.Unlock()
	if er != nil {
		if ca != nil {

			s.repo.FromReturn.Lock()

			delete(s.repo.MapForStream, ca) ///huncha kki hunna as outsiide loop
			s.repo.FromReturn.Unlock()
			ca.Close(websocket.StatusNormalClosure, "cross origin WebSocket accepted")
		}
		return
	}

	// Periodically update the player turn

	s.repo.Mutex3.Lock()
	defer s.repo.Mutex3.Unlock()

	s.repo.GlobalCurrentName = s.repo.ListOfAllNames[0].Name
	for { //# esma khasma only broadcast kaam nothing else broadcast of break word for red container and broadcast of currentName on which drawing
		s.repo.CountForTimer = 0.0
		for s.repo.ToogleForTimer {

			time.Sleep(time.Millisecond * 500)

			if s.repo.CountForTimer = s.repo.CountForTimer + 0.5; s.repo.CountForTimer == 20 {

				s.repo.ToogleForProgressBar = true
				s.repo.CountForTimer = 0
				break
			}
		}
		s.repo.ToogleForTimer = true
		//@ this is the ensure that the timer works nicely. after 5sec completes it automatically exits but if in between the drawer exits then also this will not  makee others wait. toogleForTimer is used as =false in above exit sectiion so this method will exit and again set to true for next iteration.

		s.repo.Ind++
		if (s.repo.Index + 1) < len(s.repo.ListOfAllNames) {
			s.repo.Index = s.repo.Index + 1
		} else {
			s.repo.Index = 0
		}
		if len(s.repo.ListOfAllNames) == 0 {
			return
		}
		currentName := s.repo.ListOfAllNames[s.repo.Index].Name
		s.repo.GlobalCurrentName = currentName
		for kz := range s.repo.MapForStream {

			kz.Write(ctx, websocket.MessageText, []byte("Break"))
			//! at this pause is for the red container at which post is made for getting the
			//! value for drawing.
		}
		//?problrm here is small one now ::::   jaba break bhanne sab lai pathaisake pachi red container display huncha and if another player gets added then the red cotainer is not displayed as break bhanne keyword pathaudaiina . or eevery second pathauna paryo break keyword . But this is only for that period of time after that everything is NORMAL.
		if len(s.repo.ListOfAllNames) == 0 {

			return
		} //!yo condition kina mathi lyako hola bhanda to return the lock if ii dont then yo sleep ta 2o sec ho chalcha sure and lock dinu parcha so unlock garna parchha so that aaune le 40 seconds chai atleast chalairakhos . and as long as the timer of below is lesser no problem . baal chaina yes eeuta extrra resource chai consume bhaiirako cha.

		//@ COMPULSORILY yo red container lai we can use channel AS NABHAE SLEEP HUDA ARKO AAUNE LE 10 SEC EXTRA KURNA PARCHA AS LOCK RELEASE BHAKO HUNNA . IF STATEMENT IS EXPENSIVE .
		time.Sleep(time.Second * 5)
		s.repo.ToogleForProgressBar = false

		//!pause for red container BREAK CONTAINER

		for kz := range s.repo.MapForStream {

			kz.Write(ctx, websocket.MessageText, []byte(currentName))

		}

	}
}

// AddPlayer takes the current player name and inserts the value in the list to
// update the list of players, then returns the first player's name.
func (s *GameService) AddPlayer(nameOfCurrentPlayer string) string {
	s.repo.Mutex2.Lock()

	s.repo.ListOfAllNames = append(s.repo.ListOfAllNames, models.PlayerPoints{Name: nameOfCurrentPlayer, Points: 0})

	s.repo.NameForMap <- nameOfCurrentPlayer

	firstPlayerName := s.repo.ListOfAllNames[0].Name
	s.repo.Mutex2.Unlock()

	return firstPlayerName
}

func (s *GameService) GetPlayers() []models.PlayerPoints {
	return s.repo.ListOfAllNames
}

func (s *GameService) GetCurrentWord() string {
	if s.repo.Ind >= len(s.repo.Slices) {
		s.repo.Ind = 0 //lock system for shared variable.
	}
	return s.repo.Slices[s.repo.Ind]
}

func (s *GameService) GetProgress() float64 {
	return s.repo.CountForTimer
}
