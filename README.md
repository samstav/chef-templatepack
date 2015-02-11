Template pack for FastFood
-----

### Usage
1. Download release of fastfood: https://github.com/jarosser06/fastfood/releases

2. Setup a fastfood.json which is used to generate your cookbook - see examples below.

3. Clone the template pack locally so that you can contribute :)

4. ```fastfood build -template-pack ../path/to/chef-templatepack -cookbooks-path . fastfood.json```


Example fastfood.json files for various projects:
-----

### Wordpress
```{
  "name": "wordpress",
  "stencils": [
    {
      "name": "mywebsite.com",
      "stencil_set": "wordpress"
    },
    {
      "stencil_set": "php"
    },
    {
      "stencil_set": "nginx"
    },
    {
      "stencil_set": "mariadb"
    }
  ]
}```
