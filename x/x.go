package main

import (
	"context"
	"errors"
	"fmt"
)

func main() {
	a, err := GetA(context.Background(), "100")
	if err != nil {
		panic(err)
	}
	if !a.Exists {
		fmt.Println("a is nil")
	}
	fmt.Println(a, err)
}

type A struct {
	ID string
}

type Optional1[T any] *T

type Optional2[T any] struct {
	Exists bool
	Value  T
}

/*
	0. 何もしない。nilチェックしないのが悪い / nilチェック忘れて本番でpanic
	1. コメントを書く / コメント読まないで0と同じ
	2. エラーにする / 呼び出す側でエラーの区別をつけてハンドリングしてない if err != nil しちゃう
	3. Optional[A]型のnilにする / 型情報を無視してnilチェック忘れてpanic
	4. Optional[*A]型の値として空の状態（ゼロ値）を返す / ちょっと扱いがめんどくさい, nilで存在しないことを表現できない
	5. boolであったか無かったか無かったかを返す / ちょっと扱いがめんどくさい
*/

// GetAはnil, nilを返すかも。
func GetA(ctx context.Context, id string) (Optional2[*A], error) {
	ErrNotFound := errors.New("not found")
	//a, err := repo.GetA(ctx, id)
	var (
		a   *A    = nil // &A{ID: id}
		err error = ErrNotFound
	)

	if errors.Is(err, ErrNotFound) {
		return Optional2[*A]{}, nil
	} else if err != nil {
		return Optional2[*A]{}, err
	}

	return Optional2[*A]{
		Exists: true,
		Value:  a,
	}, nil
}
