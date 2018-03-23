defmodule Servy.HttpServer do
  def start(port) when is_integer(port) and port > 1023 do
    {:ok, listening_socket} =
      :gen_tcp.listen(port, [:binary, packet: :raw, active: false, reuseaddr: true])

    IO.puts("\n Listening for connection requests on port #{port} ..\n")

    accept_loop(listening_socket)
  end

  def accept_loop(listen_socket) do
    IO.puts("Waiting to accept a client connection..\n")
    {:ok, client_socket} = :gen_tcp.accept(listen_socket)
    IO.puts("Connection accepted\n")

    spawn(fn -> serve(client_socket) end)

    accept_loop(listen_socket)
  end

  def serve(client_socket) do
    client_socket
    |> read_request
    |> Servy.Handler.handle()
    |> write_response(client_socket)
  end

  def read_request(client_socket) do
    {:ok, request} = :gen_tcp.recv(client_socket, 0)
    request
  end

  def generate_response(_request) do
    """
    HTTP/1.1 200 OK\r
    Content-Type: text/plain\r
    Content-Length: 6\r
    \r
    Hello!
    """
  end

  def write_response(response, client_socket) do
    :ok = :gen_tcp.send(client_socket, response)
    response
  end
end
