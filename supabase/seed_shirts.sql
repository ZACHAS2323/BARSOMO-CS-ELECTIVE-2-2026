insert into public.categories (name)
values ('Shirts')
on conflict (name) do nothing;

update public.products as product
set image_url = shirt.image_url
from public.categories as category
cross join (
  values
    (
      'Classic Cotton T-Shirt',
      'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=800&q=80'
    ),
    (
      'Graphic Print T-Shirt',
      'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?auto=format&fit=crop&w=800&q=80'
    ),
    (
      'Oversized Streetwear Tee',
      'https://images.unsplash.com/photo-1523398002811-999ca8dec234?auto=format&fit=crop&w=800&q=80'
    ),
    (
      'Classic Polo Shirt',
      'https://images.unsplash.com/photo-1618354691373-d851c5c3a990?auto=format&fit=crop&w=800&q=80'
    ),
    (
      'Long-Sleeve Henley Shirt',
      'https://images.unsplash.com/photo-1627225924765-552d49cf47ad?auto=format&fit=crop&w=800&q=80'
    )
) as shirt(name, image_url)
where product.category_id = category.id
  and category.name = 'Shirts'
  and product.name = shirt.name;

insert into public.products (
  name,
  description,
  price,
  stock,
  category_id,
  image_url
)
select
  item.name,
  item.description,
  item.price,
  item.stock,
  category.id,
  item.image_url
from (
  values
    (
      'Classic Cotton T-Shirt',
      'Everyday cotton crew-neck shirt.',
      399.00,
      25,
      'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=800&q=80'
    ),
    (
      'Graphic Print T-Shirt',
      'Soft casual shirt with a bold graphic print.',
      499.00,
      18,
      'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?auto=format&fit=crop&w=800&q=80'
    ),
    (
      'Oversized Streetwear Tee',
      'Relaxed-fit oversized shirt for everyday wear.',
      599.00,
      12,
      'https://images.unsplash.com/photo-1523398002811-999ca8dec234?auto=format&fit=crop&w=800&q=80'
    ),
    (
      'Classic Polo Shirt',
      'Smart-casual polo shirt with a comfortable collar.',
      699.00,
      15,
      'https://images.unsplash.com/photo-1618354691373-d851c5c3a990?auto=format&fit=crop&w=800&q=80'
    ),
    (
      'Long-Sleeve Henley Shirt',
      'Lightweight long-sleeve shirt with a button placket.',
      649.00,
      10,
      'https://images.unsplash.com/photo-1627225924765-552d49cf47ad?auto=format&fit=crop&w=800&q=80'
    )
) as item(name, description, price, stock, image_url)
cross join (
  select id from public.categories where name = 'Shirts'
) as category
where not exists (
  select 1
  from public.products existing
  where existing.category_id = category.id
    and existing.name = item.name
);
