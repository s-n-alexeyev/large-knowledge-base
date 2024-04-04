
First of all, try to support open source developers when you can, they invest quite a lot of their (free) time into these packages. But if you want to get rid of funding messages, you can configure NPM to turn these off. The command to do this is:

```shell
sudo npm config set fund false --location=global
```

... or if you just want to turn it off for a particular project, run this in the project directory:

```shell
npm config set fund false 
```